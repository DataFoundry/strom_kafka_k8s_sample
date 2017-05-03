import backtype.storm.task.OutputCollector;
import backtype.storm.task.TopologyContext;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.base.BaseRichBolt;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Tuple;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

/**
 * Created by tanxiang on 16/4/14.
 */
public class GlobalBolt extends BaseRichBolt {
    private static final Logger logger = LoggerFactory.getLogger(GlobalBolt.class);
    private OutputCollector outputCollector;
    private long current;

    @Override
    public void prepare(Map map, TopologyContext topologyContext, OutputCollector outputCollector) {
        this.outputCollector = outputCollector;
        current = 0;
    }

    @Override
    public void execute(Tuple tuple) {
        logger.info("tuple = [" + tuple.toString() + "]");
        current++;
        if (current / 100000 == 0) {
            logger.info("current = [" + current + "]");
            current = 0;
        }
        outputCollector.ack(tuple);
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer outputFieldsDeclarer) {
    }
}
