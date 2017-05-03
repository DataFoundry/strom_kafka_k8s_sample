import backtype.storm.Config;
import backtype.storm.LocalCluster;
import backtype.storm.StormSubmitter;
import backtype.storm.generated.AlreadyAliveException;
import backtype.storm.generated.AuthorizationException;
import backtype.storm.generated.InvalidTopologyException;
import backtype.storm.spout.SchemeAsMultiScheme;
import backtype.storm.topology.TopologyBuilder;
import backtype.storm.tuple.Fields;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import storm.kafka.*;

import java.util.Arrays;
import java.util.List;

/**
 * Created by tanxiang on 16/4/14.
 */
public class #STORMCLASSNAME# {
    private static final Logger logger = LoggerFactory.getLogger(#STORMCLASSNAME#.class);

    public static void main(String[] args) throws AlreadyAliveException, InvalidTopologyException, AuthorizationException {
        String zks = ConfProp.getInstance().getProperty("kafkaZkIpPort");
        logger.info("zks:" + zks);
        String zkRoot = ConfProp.getInstance().getProperty("kafkaZkRoot");
        logger.info("zkRoot:" + zkRoot);
        String consumerId = ConfProp.getInstance().getProperty("kafkaConsumerId");

        logger.info("consumerId:" + consumerId);
        BrokerHosts brokerHosts = new ZkHosts(zks, "/brokers");
	
        String zkServerStrs = ConfProp.getInstance().getProperty("kafkaZkIp");
	
        logger.info("zkServerStrs:" + zkServerStrs);
        List<String> zkServers = Arrays.asList(zkServerStrs.split(","));
        int zkServerPort = Integer.parseInt(ConfProp.getInstance().getProperty("kafkaZkPort"));
	
        logger.info("zkServerPort:" + zkServerPort);
        String topic = ConfProp.getInstance().getProperty("topic");
	

//        BrokerHosts brokerHosts = new ZkHosts(zks, "/brokers");
        SpoutConfig spoutConf = new SpoutConfig(brokerHosts, topic, zkRoot, consumerId);
        spoutConf.scheme = new SchemeAsMultiScheme(new StringScheme());
        spoutConf.ignoreZkOffsets = true;
        spoutConf.zkServers = zkServers;
        spoutConf.zkPort = 2181;


        TopologyBuilder topologyBuilder = new TopologyBuilder();
        // 
        topologyBuilder.setSpout("mySpout", new KafkaSpout(spoutConf), 1);
        topologyBuilder.setBolt("outputBolt", new OutputBolt(), 1)
                .shuffleGrouping("mySpout");
        topologyBuilder.setBolt("globalBolt", new GlobalBolt(), 1)
                .globalGrouping("outputBolt");
        Config conf = new Config();
        String name = "#STORMCLASSNAME#";
        if (args != null && args.length > 0) {
            conf.put(Config.NIMBUS_HOST, args[0]);
            conf.setNumAckers(0);
            conf.setNumWorkers(10);
            StormSubmitter.submitTopologyWithProgressBar(name, conf, topologyBuilder.createTopology());
        } else {
            conf.setMaxTaskParallelism(3);
            conf.setDebug(false);
            LocalCluster cluster = new LocalCluster();
            cluster.submitTopology(name, conf, topologyBuilder.createTopology());
            //Utility.threadSleep(10000);
            cluster.shutdown();
        }
    }
}
