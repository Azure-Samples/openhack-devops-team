package io.swagger.api;

import io.swagger.model.ErrorResponseDefault;
import io.swagger.model.InlineResponseDefault;
import io.swagger.model.Profile;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.annotations.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

import javax.validation.constraints.*;
import javax.validation.Valid;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.List;
@javax.annotation.Generated(value = "io.swagger.codegen.languages.SpringCodegen", date = "2018-08-03T19:26:46.543Z")

@Controller
public class UserApiController implements UserApi {

    private static final Logger log = LoggerFactory.getLogger(UserApiController.class);

    private final ObjectMapper objectMapper;

    private final HttpServletRequest request;

    @org.springframework.beans.factory.annotation.Autowired
    public UserApiController(ObjectMapper objectMapper, HttpServletRequest request) {
        this.objectMapper = objectMapper;
        this.request = request;
    }

    public ResponseEntity<Profile> updateUser(@ApiParam(value = "User's unique ID",required=true) @PathVariable("userID") String userID) {
        String accept = request.getHeader("Accept");
        if (accept != null && accept.contains("application/json")) {
            try {
                return new ResponseEntity<Profile>(objectMapper.readValue("{  \"TotalTrips\" : 5,  \"MaxSpeed\" : 3.6160767,  \"HardStops\" : 2,  \"FirstName\" : \"FirstName\",  \"Rating\" : 0,  \"CreatedAt\" : \"2000-01-23\",  \"ProfilePictureUri\" : \"\",  \"UpdatedAt\" : \"2000-01-23\",  \"Ranking\" : 6,  \"HardAccelerations\" : 7,  \"UserId\" : \"UserId\",  \"TotalTime\" : 5,  \"Id\" : \"Id\",  \"LastName\" : \"LastName\",  \"Deleted\" : true,  \"TotalDistance\" : 1.4658129,  \"FuelConsumption\" : 9.301444}", Profile.class), HttpStatus.NOT_IMPLEMENTED);
            } catch (IOException e) {
                log.error("Couldn't serialize response for content type application/json", e);
                return new ResponseEntity<Profile>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }

        return new ResponseEntity<Profile>(HttpStatus.NOT_IMPLEMENTED);
    }

    public ResponseEntity<Profile> userPOST(@ApiParam(value = "User's unique ID",required=true) @PathVariable("userID") String userID,@ApiParam(value = "Details of the profile" ,required=true )  @Valid @RequestBody Profile profile) {
        String accept = request.getHeader("Accept");
        if (accept != null && accept.contains("application/json")) {
            try {
                return new ResponseEntity<Profile>(objectMapper.readValue("{  \"TotalTrips\" : 5,  \"MaxSpeed\" : 3.6160767,  \"HardStops\" : 2,  \"FirstName\" : \"FirstName\",  \"Rating\" : 0,  \"CreatedAt\" : \"2000-01-23\",  \"ProfilePictureUri\" : \"\",  \"UpdatedAt\" : \"2000-01-23\",  \"Ranking\" : 6,  \"HardAccelerations\" : 7,  \"UserId\" : \"UserId\",  \"TotalTime\" : 5,  \"Id\" : \"Id\",  \"LastName\" : \"LastName\",  \"Deleted\" : true,  \"TotalDistance\" : 1.4658129,  \"FuelConsumption\" : 9.301444}", Profile.class), HttpStatus.NOT_IMPLEMENTED);
            } catch (IOException e) {
                log.error("Couldn't serialize response for content type application/json", e);
                return new ResponseEntity<Profile>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }

        return new ResponseEntity<Profile>(HttpStatus.NOT_IMPLEMENTED);
    }

}
