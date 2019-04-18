<%namespace file="ie.mako" name="ie"/>
<%
import os
import shutil
import time
import subprocess

# Sets ID and sets up a lot of other variables
ie_request.load_deploy_config()
ie_request.attr.docker_port = 3838


# Create tempdir in galaxy
#temp_dir = ie_request.temp_dir
#PASSWORD = ie_request.notebook_pw
#USERNAME = "galaxy"

# Did the user give us an RData file?
#if hda.datatype.__class__.__name__ == "RData":
#    shutil.copy( hda.file_name, os.path.join(temp_dir, '.RData') )
#will put the right file here  
#data type definition
#/galaxy-central/lib/galaxy/datatypes  

dataset_classes = ["MzXML", "MzML", "NetCDF"]

#main_dataset = ie_request.volume(hda.file_name, '/srv/shiny-server/samples/chromato_visu/inputdata.dat', how='ro')
main_dataset = ie_request.volume('/srv/shiny-server/samples/chromato_visu/inputdata.dat', hda.file_name, mode='ro')
dataset_list = []
dataset_list.append(main_dataset)

for dataset in hda.history.datasets :
	if dataset.name == hda.name :
		continue	
	if dataset.datatype.__class__.__name__ in dataset_classes :
		#other_dataset = ie_request.volume(dataset.file_name, '/srv/shiny-server/samples/chromato_visu/%s'%dataset.name, how='ro')
		other_dataset = ie_request.volume('/srv/shiny-server/samples/chromato_visu/%s'%dataset.name, dataset.file_name, mode='ro')
		if other_dataset not in dataset_list :
			dataset_list.append(other_dataset)
		else :
			dataset_list.replace(other_dataset, other_dataset)

#ie_request.launch(volumes=[main_dataset],env_override={
ie_request.launch(volumes=dataset_list,env_override={
    'PUB_HOSTNAME': ie_request.attr.HOST,
    'ORIGIN_FILENAME': hda.name,
})

## General IE specific
# Access URLs for the notebook from within galaxy.
# TODO: Make this work without pointing directly to IE. Currently does not work
# through proxy.
#notebook_access_url = ie_request.url_template('${PROXY_URL}/?')
notebook_access_url = ie_request.url_template('${PROXY_URL}/samples/chromato_visu/?')
#notebook_pubkey_url = ie_request.url_template('${PROXY_URL}/rstudio/auth-public-key')
#notebook_access_url = ie_request.url_template('${PROXY_URL}/rstudio/')
#notebook_login_url =  ie_request.url_template('${PROXY_URL}/rstudio/auth-do-sign-in')
#notebook_access_url = ie_request.url_template('${PROXY_URL}/?bam=http://localhost/tmp/bamfile.bam')

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

        requirejs(['galaxy.interactive_environments', 'plugin/chromato'], function(){
            display_spinner();
        });

        toastr.info(
            "Loading data into the App",
            "...",
            {'closeButton': true, 'timeOut': 5000, 'tapToDismiss': false}
        );

        var startup = function(){
           // Load notebook
           requirejs(['galaxy.interactive_environments','plugin/chromato'], function(IES){
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
