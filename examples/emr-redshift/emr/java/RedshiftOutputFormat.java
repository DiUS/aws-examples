package au.com.dius.redshift;

import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.OutputFormat;
import org.apache.hadoop.mapred.RecordWriter;
import org.apache.hadoop.util.Progressable;

import java.io.IOException;

public class RedshiftOutputFormat implements OutputFormat {

  @java.lang.Override
  public RecordWriter getRecordWriter(FileSystem fileSystem, JobConf jobConf, java.lang.String string, Progressable progressable) throws IOException {
    return null;
  }

  @java.lang.Override
  public void checkOutputSpecs(FileSystem fileSystem, JobConf jobConf) throws IOException {
  }
}
