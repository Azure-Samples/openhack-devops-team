package io.swagger.api;

import io.swagger.model.Healthcheck;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
@javax.annotation.Generated(value = "io.swagger.codegen.languages.SpringCodegen", date = "2018-08-03T19:26:46.543Z")

@Controller
public class HealthcheckApiController implements HealthcheckApi {

    private static final Logger log = LoggerFactory.getLogger(HealthcheckApiController.class);

    private final ObjectMapper objectMapper;

    private final HttpServletRequest request;

    @org.springframework.beans.factory.annotation.Autowired
    public HealthcheckApiController(ObjectMapper objectMapper, HttpServletRequest request) {
        this.objectMapper = objectMapper;
        this.request = request;
    }

    public ResponseEntity<Healthcheck> healthcheckUserGet() {

        try {
            return new ResponseEntity<Healthcheck>(objectMapper.readValue("{  \"message\" : \"healthcheck\",  \"status\" : \"healthy\"}", Healthcheck.class), HttpStatus.OK);
        } catch (IOException e) {
            log.error("Couldn't serialize response for content type application/json", e);
            return new ResponseEntity<Healthcheck>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

}
