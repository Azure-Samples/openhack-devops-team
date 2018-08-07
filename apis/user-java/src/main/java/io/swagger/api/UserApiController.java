package io.swagger.api;

import io.swagger.model.Profile;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.annotations.*;
import io.swagger.repository.UserRepositoryService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;

import javax.validation.Valid;
import javax.servlet.http.HttpServletRequest;
@javax.annotation.Generated(value = "io.swagger.codegen.languages.SpringCodegen", date = "2018-08-03T19:26:46.543Z")

@Controller
public class UserApiController implements UserApi {

    private static final Logger log = LoggerFactory.getLogger(UserApiController.class);

    private ObjectMapper objectMapper;

    private HttpServletRequest request;

    @Autowired
    UserRepositoryService userRepositoryService;

    @org.springframework.beans.factory.annotation.Autowired
    public UserApiController(ObjectMapper objectMapper, HttpServletRequest request) {
        this.objectMapper = objectMapper;
        this.request = request;
    }

    public ResponseEntity<Profile> updateUser(@ApiParam(value = "User's unique ID",required=true) @PathVariable("userID") String userID,@ApiParam(value = "Details of the profile" ,required=true )  @Valid @RequestBody Profile profile) {
        String accept = request.getHeader("Accept");
        if (accept != null && accept.contains("application/json")) {
            try {
                profile.setId(userID);
                Profile updatedUser = userRepositoryService.update(profile);
                return new ResponseEntity<Profile>(updatedUser, HttpStatus.OK);
            } catch (Exception e) {
                log.error("Error updating user profile", e.getMessage());
                return new ResponseEntity<Profile>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }

        return new ResponseEntity<Profile>(HttpStatus.NOT_IMPLEMENTED);
    }

    public ResponseEntity<Profile> userPOST(@ApiParam(value = "User's unique ID",required=true) @PathVariable("userID") String userID,@ApiParam(value = "Details of the profile" ,required=true )  @Valid @RequestBody Profile profile) {
        String accept = request.getHeader("Accept");
        if (accept != null && accept.contains("application/json")) {
            try {
                return new ResponseEntity<Profile>(userRepositoryService.save(profile), HttpStatus.OK);
            } catch (Exception e) {
                log.error("Couldn't create new profile", e.getMessage());
                return new ResponseEntity<Profile>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }

        return new ResponseEntity<Profile>(HttpStatus.NOT_IMPLEMENTED);
    }

}