package au.com.dius.redshift;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.FileInputFormat;
import org.apache.hadoop.mapred.FileOutputFormat;
import org.apache.hadoop.mapred.JobClient;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.lib.IdentityReducer;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.mahout.classifier.bayes.XmlInputFormat;


public class ArtistJob implements Tool {

  private Configuration conf;

  public static void main(String[] args) throws Exception {
    int res = ToolRunner.run(new Configuration(), new ArtistJob(), args);
    System.exit(res);
  }

  @Override
  public int run(String[] strings) throws Exception {
    JobConf job = new JobConf(conf, ArtistJob.class);

    conf.set("xmlinput.start", "");
    conf.set("xmlinput.end", "");


    FileInputFormat.setInputPaths(job, "s3n://aws-examples.dius.com.au/discogs_20130801_artists.xml");
    job.setJarByClass(ArtistJob.class);
    job.setMapperClass(ArtistMapper.class);
    job.setReducerClass(IdentityReducer.class);

    job.setInputFormat(XmlInputFormat.class);

    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(NullWritable.class);
    Path outPath = new Path("hdfs:///artists");
    FileOutputFormat.setOutputPath(job, outPath);

    FileSystem dfs = FileSystem.get(outPath.toUri(), conf);
    if (dfs.exists(outPath)) {
      dfs.delete(outPath, true);
    }
    JobClient.runJob(job);
    return 0;
  }

  @Override
  public void setConf(Configuration conf) {
    this.conf = conf;
  }

  @Override
  public Configuration getConf() {
    return conf;
  }
}
