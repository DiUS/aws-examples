require 'aws-sdk'
require 'pg'

module Dius
  module Aws

    AWS_ACCESS_KEY = ENV['AWS_ACCESS_KEY']
    AWS_SECRET_KEY = ENV['AWS_SECRET_KEY']
    AWS_REGION = ENV['AWS_REGION']

    AWS.config(:access_key_id => AWS_ACCESS_KEY, :secret_access_key => AWS_SECRET_KEY)

    def s3
      s3 = AWS::S3.new
    end

    def emr
      AWS::EMR.new(:region => AWS_REGION)
    end

    def redshift
      AWS::Redshift.new(:ec2_endpoint => "ec2.#{AWS_REGION}.com")
    end

    def s3_put(file, s3_path)
      if s3_path.start_with?('s3://')
        s3_path = s3_path[5..-1]
      end

      bucket = s3_path.slice(0, s3_path.index("/"))
      path = s3_path.slice(s3_path.index("/") + 1, s3_path.length)

      object = s3.buckets[bucket].objects[path + "/" + File.basename(file)]
      object.write(Pathname.new(file))
    end

    def emr_run_flow(name, debug = true)
      flow_config = {
          :name => name,
          :log_uri => "s3n://aws-examples.dius.com.au/logs",
          :ami_version => "latest",
          :instances => {
              :master_instance_type => "m1.small",
              :slave_instance_type => "m1.small",
              :instance_count => 2,
              :ec2_key_name => "default",
              :keep_job_flow_alive_when_no_steps => true,
          },
          :bootstrap_actions => [],
          :steps => []
      }

      if debug
        flow_config[:steps].push({
            :name => "Enable debugging",
            :hadoop_jar_step => {
                :jar => "s3://elasticmapreduce/libs/script-runner/script-runner.jar",
                :args => [
                  "s3://elasticmapreduce/libs/state-pusher/0.1/fetch"
                ]
            }
        })
      end

      if block_given?
        yield flow_config
      end
      response = emr.client.run_job_flow(flow_config)
      return response[:job_flow_id]
    end

    def emr_run_script(job_flow_id, name, script)
      step_config = {
          :job_flow_id => job_flow_id,
          :steps => [{
              :name => name,
              :action_on_failure => "CANCEL_AND_WAIT",
              :hadoop_jar_step => {
                  :jar => "s3://elasticmapreduce/libs/script-runner/script-runner.jar",
                  :args => [ script ]
              }
          }]
      }

      if block_given?
        yield step_config[:steps][0]
      end
      emr.client.add_job_flow_steps(step_config)
    end

    def emr_add_hive_step(job_flow_id, name)
      step_config = {
          :job_flow_id => job_flow_id,
          :steps => [{
            :name => name,
            :action_on_failure => "CANCEL_AND_WAIT",
            :hadoop_jar_step => {
               :jar => "s3://elasticmapreduce/libs/script-runner/script-runner.jar",
               :args => [
                "s3://#{AWS_REGION}.elasticmapreduce/libs/hive/hive-script",
                "--base-path", "s3://#{AWS_REGION}.elasticmapreduce/libs/hive",
                "--hive-versions", "latest"
              ]
            }
          }]
      }

      if block_given?
        yield step_config[:steps][0]
      end
      emr.client.add_job_flow_steps(step_config)
    end

    def emr_add_distcp_step(job_flow_id, name)
      step_config = {
        :job_flow_id => job_flow_id,
        :steps => [{
            :name => name,
            :action_on_failure => "CANCEL_AND_WAIT",
            :hadoop_jar_step => {
                :jar => "/home/hadoop/lib/emr-s3distcp-1.0.jar",
                :args => []
            }
        }]
      }

      if block_given?
        yield step_config[:steps][0]
      end
      emr.client.add_job_flow_steps(step_config)
    end

    def emr_add_streaming_step(job_flow_id, name)
      step_config = {
        :job_flow_id => job_flow_id,
        :steps => [{
             :name => name,
             :action_on_failure => "CANCEL_AND_WAIT",
             :hadoop_jar_step => {
                 :jar => "/home/hadoop/contrib/streaming/hadoop-streaming.jar",
                 :args => []
             }
         }]
      }

      if block_given?
        yield step_config[:steps][0]
      end
      emr.client.add_job_flow_steps(step_config)
    end

    def emr_add_sqoop_export_step(job_flow_id, name)
      step_config = {
        :job_flow_id => job_flow_id,
        :steps => [{
          :name => name,
          :action_on_failure => "CANCEL_AND_WAIT",
          :hadoop_jar_step => {
             :jar => "s3n://aws-examples.dius.com.au/lib/sqoop-1.4.4.jar",
             :main_class => "org.apache.sqoop.Sqoop",
             :args => [
                 "export",
                 "--driver", "org.postgresql.Driver",
                 "--input-fields-terminated-by", "\t",
                 "--input-null-string", "NULL",
                 "--input-null-non-string", "NULL",
                 "--direct",
                 "--verbose"
             ]
          }
        }]
      }

      if block_given?
        yield step_config[:steps][0]
      end
      emr.client.add_job_flow_steps(step_config)
    end


    def redshift_create_cluster(cluster_id)
      cluster_config = {
          :cluster_identifier => cluster_id,
          :cluster_type => 'single-node',
          :node_type => 'dw.hs1.xlarge',
          :publicly_accessible => true
      }
      if block_given?
        yield cluster_config
      end
      response = redshift.client.create_cluster(cluster_config)
    end

    def redshift_with_cluster(cluster_id)
      response = redshift.client.describe_clusters(:cluster_identifier => cluster_id)
      unless response.clusters.count == 1
        raise ArgumentError, "Cluster id #{cluster_id} matched #{response.clusters.count} clusters, expected 1"
      end

      if block_given?
        yield response.clusters.first
      else
        return response.clusters.first
      end
    end

    def redshift_wait(cluster_id, expected_status, timeout = 120)
      Timeout::timeout(timeout) do
        status = 'unknown'
        while status != expected_status
          begin
            cluster(cluster_id) do |cluster|
              status = cluster.cluster_status
            end
          rescue ArgumentError
            sleep 1
          end
        end
      end
    end

    def redshift_with_connection(cluster_id, username, password)
      conn = nil
      redshift_with_cluster(cluster_id) do |cluster|
        conn = PG::Connection.open(
            :host => cluster.endpoint.address,
            :port => cluster.endpoint.port,
            :dbname => cluster.db_name,
            :user => username,
            :password => password
        )
      end

      if block_given?
        yield conn
      else
        return conn
      end
    end


  end
end
