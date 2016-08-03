
g.info("input is:"+ @input.to_s)

hostname=                  @input.get("hostname")
servicestate=              @input.get("servicestate")
hostaddress=               @input.get("hostaddress")
hoststatetype=             @input.get("hoststatetype")
servicedisplayname=		   @input.get("servicedisplayname")
servicestate=			   @input.get("servicestate")
servicestatetype=           @input.get("servicestatetype")
servicedesc=               @input.get("servicedesc")
servicestateid=			   @input.get("servicestateid")
serviceeventid=            @input.get("serviceeventid")
serviceproblemid=          @input.get("serviceproblemid")
serviceexecutiontime=      @input.get("serviceexecutiontime")
serviceduration=           @input.get("serviceduration")
manageenginerequestid=     @input.get("MANAGE_ENGINE_REQUESTID")
serviceattempt=            @input.get("serviceattempt")


@log.info("restart_httpd was called for host "+ hostname +"Related incident Ticket Number : "+ manageenginerequestid )

   response=@call.connector("manageenginesdp")    
              .set("action","update-request")
              .set("request-id",manageenginerequestid.to_i)
              .set("requester","Flint Operator")
              .set("subject","Flint attempted Restarting the Service")
              .set("description","Flint will attempt to ssh to "+ hostaddress +" and restart "+ servicedesc)
              .set("requesttemplate","Unable to browse")
              .set("priority","Low")
              .set("site","-")
              .set("group","Network")
              .set("technician","Flint Operator")
              .set("level","Tier 3")
              .set("status","Close")
              .set("service",@service)
              .timeout(10000)                                                 
              .async
    
#    result=response.get("result")
#    @log.info("#{result.to_s}")

if servicestate == "CRITICAL"                                       #service goes ‘Down’
  response=@call.connector("ssh")                                   #calling ssh connector   
	.set("target",hostaddress)
	.set("type","exec")             
	.set("username","root")
	.set("password","Flint@01")
	.set("command"," mysql -h "192.168.1.164" -u "root" "-pFlint@01" "information_schema" <"resolve.txt"")     #Mysql connection resolution.
	.set("timeout",60000)
	.sync

  #SSH Connector Response Parameter
#  resultfromaction=response.get("result")
#  @log.info("#{resultfromaction.to_s}")



	  # closing request 
	response2=@call.connector("manageenginesdp")    
              .set("action","close-request")
              .set("request-id",manageenginerequestid.to_i)
              .set("close-accepted","Accepted")
              .set("close-comment","Service restarted successfully")                               
              .aync


#    resulti=response2.get("result")
#    @log.info("#{resulti.to_s}")

end

