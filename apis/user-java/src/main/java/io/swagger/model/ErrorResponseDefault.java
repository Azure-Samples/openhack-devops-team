package io.swagger.model;

import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModelProperty;
import org.springframework.validation.annotation.Validated;

/**
 * ErrorResponseDefault
 */
@Validated
@javax.annotation.Generated(value = "io.swagger.codegen.languages.SpringCodegen", date = "2018-08-03T19:26:46.543Z")

public class ErrorResponseDefault   {
  @JsonProperty("status")
  private Integer status = null;

  @JsonProperty("message")
  private String message = null;

  public ErrorResponseDefault status(Integer status) {
    this.status = status;
    return this;
  }

  /**
   * Error code (if available)
   * @return status
  **/
  @ApiModelProperty(value = "Error code (if available)")


  public Integer getStatus() {
    return status;
  }

  public void setStatus(Integer status) {
    this.status = status;
  }

  public ErrorResponseDefault message(String message) {
    this.message = message;
    return this;
  }

  /**
   * Error Message
   * @return message
  **/
  @ApiModelProperty(value = "Error Message")


  public String getMessage() {
    return message;
  }

  public void setMessage(String message) {
    this.message = message;
  }


  @Override
  public boolean equals(java.lang.Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    ErrorResponseDefault errorResponseDefault = (ErrorResponseDefault) o;
    return Objects.equals(this.status, errorResponseDefault.status) &&
        Objects.equals(this.message, errorResponseDefault.message);
  }

  @Override
  public int hashCode() {
    return Objects.hash(status, message);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class ErrorResponseDefault {\n");
    
    sb.append("    status: ").append(toIndentedString(status)).append("\n");
    sb.append("    message: ").append(toIndentedString(message)).append("\n");
    sb.append("}");
    return sb.toString();
  }

  /**
   * Convert the given object to string with each line indented by 4 spaces
   * (except the first line).
   */
  private String toIndentedString(java.lang.Object o) {
    if (o == null) {
      return "null";
    }
    return o.toString().replace("\n", "\n    ");
  }
}

