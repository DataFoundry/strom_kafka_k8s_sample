import backtype.storm.task.OutputCollector;
import backtype.storm.task.TopologyContext;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.base.BaseRichBolt;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Tuple;
import backtype.storm.tuple.Values;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

/**
 * Created by tanxiang on 16/4/14.
 */
public class OutputBolt extends BaseRichBolt {
    private static final Logger logger = LoggerFactory.getLogger(OutputBolt.class);
    private OutputCollector outputCollector;

    @Override
    public void prepare(Map map, TopologyContext topologyContext, OutputCollector outputCollector) {
        this.outputCollector = outputCollector;
    }

    @Override
    public void execute(Tuple tuple) {
        String tupleStr = tuple.toString();
//        logger.info("tuple = [" + tupleStr + "]");
        String tupleComponent = tuple.getSourceComponent();
        //logger.info("tuple SourceComponent= [" + tupleComponent + "]");
        String tupleStreamId = tuple.getSourceStreamId();
        //logger.info("tuple SourceStreamId= [" + tupleStreamId + "]");
        String tupleGlabalId = tuple.getSourceGlobalStreamid().toString();
        //logger.info("tuple SourceGlobalStreamid= [" + tupleGlabalId + "]");
        String tupleTask = tuple.getSourceTask() + "";
        //logger.info("tuple SourceTask= [" + tupleTask + "]");
        String tupleContent = tuple.getString(0);
        logger.info("tupleContent = [" + tupleContent + "]");

        outputCollector.emit(tuple, new Values(tupleStr, tupleComponent, tupleStreamId, tupleGlabalId, tupleTask));
        outputCollector.ack(tuple);
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer outputFieldsDeclarer) {
        outputFieldsDeclarer.declare(new Fields("tuplestr", "component:", "streamid", "globalid", "task"));
    }
}
