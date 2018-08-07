/**
 * NOTE: This class is auto generated by the swagger code generator program (2.3.1).
 * https://github.com/swagger-api/swagger-codegen
 * Do not edit the class manually.
 */
package io.swagger.api;

import io.swagger.model.ErrorResponseDefault;
import io.swagger.model.InlineResponseDefault;
import io.swagger.model.Profile;
import io.swagger.annotations.*;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

import javax.validation.Valid;
import javax.validation.constraints.*;
import java.util.List;
@javax.annotation.Generated(value = "io.swagger.codegen.languages.SpringCodegen", date = "2018-08-03T19:26:46.543Z")

@Api(value = "user", description = "the user API")
public interface UserApi {

    @ApiOperation(value = "", nickname = "updateUser", notes = "Update User", response = Profile.class, tags={  })
    @ApiResponses(value = { 
        @ApiResponse(code = 200, message = "User Updated", response = Profile.class),
        @ApiResponse(code = 404, message = "User profile not found"),
        @ApiResponse(code = 200, message = "Unknown Error", response = ErrorResponseDefault.class) })
    @RequestMapping(value = "/user/{userID}",
        produces = { "application/json" }, 
        consumes = { "application/json" },
        method = RequestMethod.PATCH)
    ResponseEntity<Profile> updateUser(@ApiParam(value = "User's unique ID",required=true) @PathVariable("userID") String userID,@ApiParam(value = "Details of the profile" ,required=true )  @Valid @RequestBody Profile profile);

    @ApiOperation(value = "", nickname = "userPOST", notes = "Declares and creates a new profile", response = Profile.class, tags={  })
    @ApiResponses(value = { 
        @ApiResponse(code = 201, message = "Creation successful", response = Profile.class),
        @ApiResponse(code = 200, message = "An error occurred", response = InlineResponseDefault.class) })
    @RequestMapping(value = "/user/{userID}",
        produces = { "application/json" }, 
        consumes = { "application/json" },
        method = RequestMethod.POST)
    ResponseEntity<Profile> userPOST(@ApiParam(value = "User's unique ID",required=true) @PathVariable("userID") String userID,@ApiParam(value = "Details of the profile" ,required=true )  @Valid @RequestBody Profile profile);

}
