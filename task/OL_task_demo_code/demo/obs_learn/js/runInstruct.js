var pagenum = 0;    // holds current page number
var choice = [];    // holds keys available from current page

// Fullscreen
var go_full = {
    type: "fullscreen",
    fullscreen_mode: true,
    data: {
        label: "go_full",
    },
};

var kickout = {
    type: "html-keyboard-response",
    stimulus: "",
    data: {label: "kickout"},
    on_start: function(trial) {
        trial.stimulus = errorHTML;
    },
    choices: jsPsych.NO_KEYS,
    trial_duration: null,
    response_ends_trial: false,
};

// dummy event
var initInstruct = {
    type: "html-keyboard-response",
    stimulus: "<body><div></div></body>",
    choices: jsPsych.NO_KEYS,
    trial_duration: 0,
    response_ends_trial: false,
    data: {
        label: "initInstruct",
        page_index: pagenum,
        pageStep: 1,    // holds 1 if stepping to next page, -1 if stepping to previous
        designNumber: OL_designNo
    },
};

var instruct_page = {
    type: "html-keyboard-response",
    // dummy stimulus and key choices are reset in on_start()
    stimulus: "<body><div></div></body>",
    choices: jsPsych.NO_KEYS,
    trial_duration: null,
    response_ends_trial: true,
    data: {label: 'instruction'},
    on_start: function (trial) {
        var prev_data = jsPsych.data.get().last(1).values()[0];
        pagenum = prev_data.page_index + prev_data.pageStep;
        trial.stimulus = '<body><div class="centered"><img src=' + instruct_pages[pagenum-1] + ' alt="instruction" width="100%"></div></body>';
        if (pagenum == 1) {
            trial.choices = [' '];
        } else {
            if (choiceKey_array[pagenum-1][0] == null) {
                trial.choices = ['z'];
                trial.trial_duration = ITIdur;
            } else {
                trial.choices = [choiceKey_array[pagenum-1][0], choiceKey_array[pagenum-1][1]];
            }
        }
    },
    on_finish: function (data) {
        data.page_index = pagenum;
        // set pageStep, which will be added to page_index to compute the next pagenum
        if (pagenum == 1) {
            if (jsPsych.pluginAPI.compareKeys(data.key_press,' ')) {data.pageStep = 1}
        } else {
            if (choiceKey_array[pagenum-1][0] == null) {
                if (data.key_press == null) {
                    data.pageStep = 1
                } else if (jsPsych.pluginAPI.compareKeys(data.key_press,choiceKey_array[pagenum-1][1])) {
                    data.pageStep = -1
                }
            } else {
                if (jsPsych.pluginAPI.compareKeys(data.key_press,choiceKey_array[pagenum-1][0])) {
                    data.pageStep = 1
                } else if (jsPsych.pluginAPI.compareKeys(data.key_press,choiceKey_array[pagenum-1][1])) {
                    data.pageStep = -1
                }
            }
        }
    }
};


// timeline for one trial, combine ifnodes and fixed events
var instruct_trialLoop = {
    timeline: [instruct_page],
    // use a loop function to play instruct_page event with different instruction pages
    // until all instruction pages have been shown
    loop_function: function (data) {
        var prev_data = data.values()[0];
        console.log(prev_data.page_index)
        if (prev_data.pageStep < 0 || prev_data.page_index < Ninstruct) {
            return true;
        }
        else {
            console.log("out of pages.");
            return false;
        }
    }
};

var instruct_trialProcedure = {
    timeline: [initInstruct, instruct_trialLoop],
};
