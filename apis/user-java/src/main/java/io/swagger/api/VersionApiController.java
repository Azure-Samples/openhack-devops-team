package io.swagger.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import javax.servlet.http.HttpServletRequest;

@javax.annotation.Generated(value = "io.swagger.codegen.languages.SpringCodegen", date = "2018-08-03T19:26:46.543Z")

@Controller
public class VersionApiController implements VersionApi {
    private static final Logger log = LoggerFactory.getLogger(VersionApiController.class);
    private final HttpServletRequest request;
    private ObjectMapper objectMapper;
    
    @org.springframework.beans.factory.annotation.Autowired
    public VersionApiController(ObjectMapper objectMapper, HttpServletRequest request) {
        this.objectMapper = objectMapper;
        this.request = request;
    }

    @Override
    public ResponseEntity<String> versionGet() {
        String version = System.getenv("APP_VERSION");
        return new ResponseEntity<String>(version, HttpStatus.OK);
    }

}
