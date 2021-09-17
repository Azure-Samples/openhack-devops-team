package io.swagger.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.Contact;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@javax.annotation.Generated(value = "io.swagger.codegen.languages.SpringCodegen", date = "2018-08-03T19:26:46.543Z")

@Configuration
@EnableSwagger2
@EnableWebMvc
public class SwaggerDocumentationConfig extends WebMvcConfigurerAdapter {

    ApiInfo apiInfo() {
        return new ApiInfoBuilder()
            .title("My Driving User Java API")
            .description("API for the user in the My Driving example app. https://github.com/Azure-Samples/openhack-devops-team")
            .license("")
            .licenseUrl("http://unlicense.org")
            .termsOfServiceUrl("")
            .version("0.1.0")
            .contact(new Contact("","", ""))
            .build();
    }

    @Bean
    public Docket customImplementation(){
        return new Docket(DocumentationType.SWAGGER_2)
                .select()
                    .apis(RequestHandlerSelectors.basePackage("io.swagger.api"))
                    .paths(PathSelectors.any())
                    .build()
                    .pathMapping("/")
                .directModelSubstitute(org.threeten.bp.LocalDate.class, java.sql.Date.class)
                .directModelSubstitute(org.threeten.bp.OffsetDateTime.class, java.util.Date.class)
                .apiInfo(apiInfo());
    }

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addRedirectViewController("/docs/user-java/api-docs", "/api-docs").setKeepQueryParams(true);
        registry.addRedirectViewController("/docs/user-java/swagger-resources/configuration/ui","/swagger-resources/configuration/ui");
        registry.addRedirectViewController("/docs/user-java/swagger-resources/configuration/security","/swagger-resources/configuration/security");
        registry.addRedirectViewController("/docs/user-java/swagger-resources", "/swagger-resources");
        registry.addRedirectViewController("/docs/user-java", "/docs/user-java/swagger-ui.html");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/docs/user-java/**").addResourceLocations("classpath:/META-INF/resources/");
    }

}
