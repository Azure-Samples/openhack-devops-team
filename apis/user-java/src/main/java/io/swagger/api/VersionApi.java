  
package io.swagger.api;

import io.swagger.annotations.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
@javax.annotation.Generated(value = "io.swagger.codegen.languages.SpringCodegen", date = "2018-08-03T19:26:46.543Z")

@Api(value = "version", description = "the version API")
public interface VersionApi {
    @ApiOperation(value = "", nickname = "versionGet", notes = "Returns version for systems looking to identify the current API version or tag", response = String.class, tags={  })
    @RequestMapping(value = "/version/user-java",
        produces = { "text/plain" }, 
        method = RequestMethod.GET)
    ResponseEntity<String> versionGet();
}
