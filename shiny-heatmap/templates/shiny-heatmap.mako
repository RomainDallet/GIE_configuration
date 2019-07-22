<%namespace file="ie.mako" name="ie"/>
<%
import os
import shutil
import time
import subprocess

# Sets ID and sets up a lot of other variables
ie_request.load_deploy_config()
ie_request.attr.docker_port = 3838

main_dataset = ie_request.volume('/srv/shiny-server/samples/heatmap/inputdata.tsv', hda.file_name, mode='ro')

ie_request.launch(volumes=[main_dataset],env_override={
    'PUB_HOSTNAME': ie_request.attr.HOST
})

## General IE specific
# Access URLs for the notebook from within galaxy.
#notebook_access_url = ie_request.url_template('${PROXY_URL}/?')
notebook_access_url = ie_request.url_template('${PROXY_URL}/samples/heatmap/?')

root = h.url_for( '/' )

%>
<html>
<head>
${ ie.load_default_js() }
</head>
<body style="margin:0px">
<script type="text/javascript">

        ${ ie.default_javascript_variables() }
        var notebook_access_url = '${ notebook_access_url }';
        ${ ie.plugin_require_config() }

        requirejs(['galaxy.interactive_environments', 'plugin/heatmap'], function(){
            display_spinner();
        });

        toastr.info(
            "Loading data into the App",
            "...",
            {'closeButton': true, 'timeOut': 5000, 'tapToDismiss': false}
        );

        var startup = function(){
           // Load notebook
           requirejs(['galaxy.interactive_environments','plugin/heatmap'], function(IES){
	      window.IES = IES
	      IES.load_when_ready(ie_readiness_url, function(){
	          load_notebook(notebook_access_url);
	      });
           });
        };
        // sleep 5 seconds
        // this is currently needed to get the vis right
        // plans exists to move this spinner into the container
        setTimeout(startup, 5000);

</script>
<div id="main">
</div>
</body>
</html>
