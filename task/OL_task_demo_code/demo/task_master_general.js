// Main task script - gets consent and runs task //

var check_consent = function (elem) {
    if (document.getElementById('consent_yes').checked == true && document.getElementById('consent_no').checked == false) {

        //run all the steps for the tasks and questionnaires
        var timeline = [];
        //preload images
        var preload_images = {
            type: 'preload',
            images: unique(preloadImages),
            continue_after_error: true,
            show_progress_bar: true,
            max_load_time: 60000,
            message: 'Please wait while the experiment loads. This may take a few minutes.',
        }
        timeline.push(preload_images);

        //go full screen
        timeline.push(go_full);

        //run OL task
        timeline.push(instruct_trialProcedure);
        timeline.push(obsvImit_practProcedure);
        timeline.push(obsvImit_trialProcedure);

        //end of demo screen
        timeline.push(endTask_procedure);

        jsPsych.init({
            timeline: timeline,
            on_finish: function() {
                console.log('The experiment is over')
                //jsPsych.data.displayData(); //can be commented out later on
            },
            on_interaction_data_update: function(data) {
                console.log(JSON.stringify(data))
            }
        })

    } else {
        console.log("No such document!");
        alert("Sorry, your database entry could not be created, probably due to your computer protection system (anti-virus, firewall, etc). We will unfortunately not be able to let you proceed with the experiment. Please return your submission now.");
    }
};

document.getElementById('header_title').innerHTML = "Welcome! Please click continue to proceed.";
document.getElementById('consent').innerHTML = "<p>\n" +
    "This demo will take you through the instructions, practice (10 trials) and 24 trials of the main task.\n" +
    "</p>\n" +
    "<hr/>\n" +
    "<h4>Do you wish to continue?</h4>\n" +
    "\n" +
    "<label class=\"container\">Yes\n" +
        "<input type=\"checkbox\" id=\"consent_yes\">\n" +
    "</label>\n" +
    "\n" +
    "<label class=\"container\">No\n" +
        "<input type=\"checkbox\" id=\"consent_no\">\n" +
    "</label>\n" +
    "<p>\n" +
    "<h3> It will take a moment to load the next page. Please be patient.</h3>\n" +
    "</p>\n" +
    "<br><br>\n" +
    "<button type=\"button\" id=\"start\" class=\"submit_button\">continue</button>\n" +
    "<br><br>";


// run task

document.getElementById("start").onclick = check_consent;

if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
    alert("Sorry, this experiment does not work on mobile devices");
    document.getElementById('consent').innerHTML ="";
}
