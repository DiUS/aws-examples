package au.com.dius.redshift;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.Mapper;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reporter;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.xml.xpath.*;
import java.io.IOException;
import java.io.StringReader;

public class ArtistMapper implements Mapper<LongWritable, Text, Text, NullWritable> {

  private static final Log log = LogFactory.getLog(ArtistMapper.class);

  private XPath xpath;
  private XPathExpression idXPath;
  private XPathExpression nameXPath;
  private XPathExpression aliasXPath;

  @Override
  public void map(LongWritable longWritable,
                  Text text,
                  OutputCollector<Text, NullWritable> outputCollector,
                  Reporter reporter) throws IOException {

    Long id;
    String name;
    Integer numbAliases;
    InputSource source = new InputSource(new StringReader(text.toString()));
    try {
      id = Long.parseLong(idXPath.evaluate(source));
      name = nameXPath.evaluate(source);
      numbAliases = ((NodeList) aliasXPath.evaluate(source, XPathConstants.NODESET)).getLength();
    } catch (XPathExpressionException e) {
      log.error("Failed to compile XPath expressions while parsing record in " + this.getClass().getName(), e);
      reporter.getCounter("ARTIST", "failure").increment(1);
      return;
    }

    outputCollector.collect(new Text(String.format("%s,%s,%s", id, name, numbAliases)), NullWritable.get());
    reporter.getCounter("ARTIST", "count").increment(1);
  }

  @Override
  public void close() throws IOException {
  }

  @Override
  public void configure(JobConf entries) {
    xpath = XPathFactory.newInstance().newXPath();
    try {
      idXPath = xpath.compile("/artist/name");
      nameXPath = xpath.compile("/artist/name");
      aliasXPath = xpath.compile("/artist/aliases/name");
    } catch (XPathExpressionException e) {
      log.error("Failed to compile XPath expressions in setup for " + this.getClass().getName(), e);
      throw new IllegalArgumentException(e);
    }
  }
}
