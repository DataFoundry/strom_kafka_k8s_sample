import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Created by tanxiang on 15/10/19.
 */
public class ConfProp extends Properties {
    private static final Logger logger = LoggerFactory.getLogger(ConfProp.class);
    private static final long serialVersionUID = -7050510458933143935L;
    private static ConfProp instance = null;

    public static synchronized ConfProp getInstance() {
        if (instance == null) {
            instance = new ConfProp();
            try {
                InputStream inputStream = ConfProp.class.getResourceAsStream("/config.properties");
                instance.load(inputStream);
            } catch (IOException ex) {
                logger.error("load config file error", ex);
            }
        }
        return instance;
    }
}
