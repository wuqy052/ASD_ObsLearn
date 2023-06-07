// Instrumental trials
// Create timeline variable
var obsvImit_Timeline_var = [];
for (var trial = 0; trial < numTotalTrials; trial++) {
    obsvImit_Timeline_var.push({
        tv_vidPath: vidPaths[trial],
        tv_leftStim: leftStimPaths[trial],
        tv_midStim: midStimPaths[trial],
        tv_rightStim: rightStimPaths[trial],
        tv_obsv_leftSelect: obsv_leftSelectPaths[trial],
        tv_obsv_midSelect: obsv_midSelectPaths[trial],
        tv_obsv_rightSelect: obsv_rightSelectPaths[trial],
        tv_play_LResp_leftStim: play_LResp_leftStim[trial],
        tv_play_LResp_midStim: play_LResp_midStim[trial],
        tv_play_LResp_rightStim: play_LResp_rightStim[trial],
        tv_play_RResp_leftStim: play_RResp_leftStim[trial],
        tv_play_RResp_midStim: play_RResp_midStim[trial],
        tv_play_RResp_rightStim: play_RResp_rightStim[trial],
        tv_goalToken: goalToken[trial],
        tv_uncertainty: uncertainty[trial],
        tv_unavAct: unavAct[trial],
        tv_corrAct: corrAct[trial],
        tv_bestAct: bestAct[trial],
        tv_vertOrd: vertOrd[trial],
        tv_horizOrd: horizOrd[trial],
        tv_video_nb: video_nb[trial],
        tv_leftOutVal: leftOutVal[trial],
        tv_rightOutVal: rightOutVal[trial],
        tv_leftOutPath: leftOutPaths[trial],
        tv_rightOutPath: rightOutPaths[trial],
        tv_allowable_keys: allowable_keys[trial],
        tv_availableKeys: availableKeys[trial],
        tv_leftAllowable: left_allowableKey[trial],
        tv_rightAllowable: right_allowableKey[trial],
        tv_blockNb: blockNb[trial],
        tv_blockID: blockID[trial],
        tv_trialID: trialID[trial],
        tv_trialType: trialType[trial],
        tv_isBreak: isBreak[trial],
        tv_designNo: OL_designNo
    });
}

// Dummy ITI
// Create a 'dummy' ITI object of duration = 0. This will store task attributes
// for conditionals later on
var dummy = {
    type: "html-keyboard-response",
    stimulus: "<head><style> body {background-color: black;} </style></head> <div></div>",
    choices: jsPsych.NO_KEYS,
    trial_duration: 0,
    response_ends_trial: false,
    data: {
        label: "dummy",
        vidPath: jsPsych.timelineVariable("tv_vidPath"),
        leftStim: jsPsych.timelineVariable("tv_leftStim"),
        midStim: jsPsych.timelineVariable("tv_midStim"),
        rightStim: jsPsych.timelineVariable("tv_rightStim"),
        obsv_leftSelect: jsPsych.timelineVariable("tv_obsv_leftSelect"),
        obsv_midSelect: jsPsych.timelineVariable("tv_obsv_midSelect"),
        obsv_rightSelect: jsPsych.timelineVariable("tv_obsv_rightSelect"),
        play_LResp_leftStim: jsPsych.timelineVariable("tv_play_LResp_leftStim"),
        play_LResp_midStim: jsPsych.timelineVariable("tv_play_LResp_midStim"),
        play_LResp_rightStim: jsPsych.timelineVariable("tv_play_LResp_rightStim"),
        play_RResp_leftStim: jsPsych.timelineVariable("tv_play_RResp_leftStim"),
        play_RResp_midStim: jsPsych.timelineVariable("tv_play_RResp_midStim"),
        play_RResp_rightStim: jsPsych.timelineVariable("tv_play_RResp_rightStim"),
        goalToken: jsPsych.timelineVariable("tv_goalToken"),
        uncertainty: jsPsych.timelineVariable("tv_uncertainty"),
        unavAct: jsPsych.timelineVariable("tv_unavAct"),
        corrAct: jsPsych.timelineVariable("tv_corrAct"),
        bestAct: jsPsych.timelineVariable("tv_bestAct"),
        vertOrd: jsPsych.timelineVariable("tv_vertOrd"),
        horizOrd: jsPsych.timelineVariable("tv_horizOrd"),
        video_nb: jsPsych.timelineVariable("tv_video_nb"),
        leftOutVal: jsPsych.timelineVariable("tv_leftOutVal"),
        rightOutVal: jsPsych.timelineVariable("tv_rightOutVal"),
        leftOutPath: jsPsych.timelineVariable("tv_leftOutPath"),
        rightOutPath: jsPsych.timelineVariable("tv_rightOutPath"),
        allowableKeys: jsPsych.timelineVariable("tv_allowable_keys"),
        availableKeys: jsPsych.timelineVariable("tv_availableKeys"),
        leftAllowKey: jsPsych.timelineVariable("tv_leftAllowable"),
        rightAllowKey: jsPsych.timelineVariable("tv_rightAllowable"),
        blockNb: jsPsych.timelineVariable("tv_blockNb"),
        blockID: jsPsych.timelineVariable("tv_blockID"),
        trialID: jsPsych.timelineVariable("tv_trialID"),
        trialType: jsPsych.timelineVariable("tv_trialType"),
        isBreak: jsPsych.timelineVariable("tv_isBreak"),
        designNo: jsPsych.timelineVariable("tv_designNo"),
    },
};

var conditionHeader = {
    type: "html-keyboard-response",
    choices: jsPsych.NO_KEYS,
    trial_duration: conditionDur,
    stimulus: function () {
        let prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        let htmlstr = "<head><style> body {background-color: black;} </style></head>" +
            '<body><div class="centered whiteText largeFont"><p><br />' +
            prev_data.trialType +
            '<br /></p></div></body>';
        return htmlstr
    },
    response_ends_trial: false,
    data: {
        label: "conditionHeader",
    },
};

var observeOn = {
    type: "html-keyboard-response",
    choices: jsPsych.NO_KEYS,
    trial_duration: observeOnDur,
    stimulus:
        function () {
            let prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
            let left = "<img src='" + prev_data.leftStim + "' height='100%' />";
            let middle = "<img src='" + prev_data.midStim + "' height='100%' />";
            let right = "<img src='" + prev_data.rightStim + "' height='100%' />";
            let video = "";
            return getObserveHTMLstr(left, middle, right, video)
        },
    response_ends_trial: false,
    data: {label: "observeOn"},
    on_start: function () {
        console.log("Observe On")
    },
};

var observeVid = {
    type: "html-keyboard-response",
    choices: jsPsych.NO_KEYS,
    trial_duration: observeVidDur+respDur,
    stimulus:
        function () {
            let prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
            let left = "<img src='" + prev_data.leftStim + "' height='100%'  id='left'/>";
            let middle = "<img src='" + prev_data.midStim + "' height='100%'  id='middle'/>";
            let right = "<img src='" + prev_data.rightStim + "' height='100%'  id='right'/>";
            let video = "<video class='video' autoplay muted>" +
                "<source src='" + prev_data.vidPath + "' type='video/mp4' >" +
                "Your browser does not support the video tag." +
                "</video>";
            let htmlstr = getObserveHTMLstr(left, middle, right, video);
            return htmlstr
        },
    response_ends_trial: false,
    data: {label: "observeVid"},
    on_start: function (trial) {
        console.log("Observe Vid");
        let prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        trial.data.video_nb = prev_data.video_nb;
    },
    on_load: function () {
        let prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        var timeout = setTimeout(function() {
            document.querySelector("#left").src = prev_data.obsv_leftSelect;
            document.querySelector("#middle").src = prev_data.obsv_midSelect;
            document.querySelector("#right").src = prev_data.obsv_rightSelect;
            clearTimeout(timeout);
        }, observeVidDur);
    },
    on_finish: function(data){
        trial_nb = trial_nb + 1;
    }
};

var playOn = {
    type: "html-keyboard-response",
    choices: function (data) {
        let prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        return [prev_data.leftAllowKey, prev_data.rightAllowKey]
    },
    trial_duration: cueDur,
    stimulus:
        function () {
            let prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
            let left ="<img src='" + prev_data.leftStim + "' height='100%' />";
            let middle = "<img src='" + prev_data.midStim + "' height='100%' />";
            let right = "<img src='" + prev_data.rightStim + "' height='100%' />";
            return getPlayHTMLstr(left, middle, right, "CHOOSE");
        },
    response_ends_trial: true,
    data: {label: "playOn"},
    on_start: function () {
        console.log("Play On")
    },
    on_finish: function (data) {
        trial_nb = trial_nb + 1;
    }
};

var left_response = {
    type: "html-keyboard-response",
    choices: jsPsych.NO_KEYS,
    stimulus:
        function () {
            let prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
            let left = "<img src='" + prev_data.play_LResp_leftStim + "' height='100%' />";
            let middle = "<img src='" + prev_data.play_LResp_midStim + "' height='100%' />";
            let right = "<img src='" + prev_data.play_LResp_rightStim + "' height='100%' />";
            return getPlayHTMLstr(left, middle, right, "CHOOSE");
        },
    trial_duration: respDur,
    response_ends_trial: false,
    data: {label: "left_response"},
    on_start: function () {console.log("Left Response")},
};

var right_response = {
    type: "html-keyboard-response",
    choices: jsPsych.NO_KEYS,
    stimulus:
        function () {
            let prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
            let left = "<img src='" + prev_data.play_RResp_leftStim + "' height='100%' />";
            let middle = "<img src='" + prev_data.play_RResp_midStim + "' height='100%' />";
            let right = "<img src='" + prev_data.play_RResp_rightStim + "' height='100%' />";
            let html = getPlayHTMLstr(left, middle, right, "CHOOSE");
            return html;
        },
    trial_duration: respDur,
    response_ends_trial: false,
    data: {label: "right_response"},
    on_start: function () {console.log("Right Response")},
};


var no_response = {
    type: 'html-keyboard-response',
    choices: jsPsych.NO_KEYS,
    stimulus: function () {
        var html = '<head><style> body {background-color: black;} </style></head>' +
            "<div class=\"centered whiteText\"><p>" +
            "Missed response! <br /><br /> Make your choice within 4 seconds." +
            "</p></div>"
        return html;
    },
    trial_duration: respDur + outDur,
    response_ends_trial: false,
    data: {label: "NA"},
    on_start: function () {console.log("Missed Response")},
};

var leftOutcome = {
    type: "html-keyboard-response",
    choices: jsPsych.NO_KEYS,
    stimulus:
        function () {
            var prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
            var html = '<head><style> body {background-color: black;} </style></head>' +
                '<body><div id="token">' +
                "    <img src='" + prev_data.leftOutPath + "' height='100%'>" +
                '</div></body>';
            return html;
        },
    trial_duration: outDur,
    response_ends_trial: false,
    data: {label: "left_outcome"},
    on_start: function () {console.log("Left outcome")},
    on_finish: function (data) {
        let prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        data.currOutcome = prev_data.leftOutVal;
        if (prev_data.availableKeys == "LM" || prev_data.availableKeys == "LR") {
            data.choice = 1;
        } else data.choice = 2;
        data.isCorr = (prev_data.corrAct == data.choice) ? 1 : 0;
        if (prev_data.leftOutPath.includes(tokenDict["1"])) {
            data.tokenShown = 1;
        } else if (prev_data.leftOutPath.includes(tokenDict["2"])) {
            data.tokenShown = 2;
        } else if (prev_data.leftOutPath.includes(tokenDict["3"])) {
            data.tokenShown = 3;
        }
        data.isGoal = (prev_data.goalToken == data.tokenShown) ? 1 : 0;
    }
};


var rightOutcome = {
    type: "html-keyboard-response",
    choices: jsPsych.NO_KEYS,
    stimulus:
        function () {
            var prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
            var html = '<head><style> body {background-color: black;} </style></head>' +
                '<body><div id="token">' +
                "    <img src='" + prev_data.rightOutPath + "' height='100%'>" +
                '</div></body>';
            return html;
        },
    trial_duration: outDur,
    response_ends_trial: false,
    data: {label: "right_outcome"},
    on_start: function () {console.log("Right outcome")},
    on_finish: function (data) {
        let prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        data.currOutcome = prev_data.rightOutVal;
        if (prev_data.availableKeys == "LR" || prev_data.availableKeys == "MR") {
            data.choice = 3;
        } else data.choice = 2;
        data.isCorr = (prev_data.corrAct == data.choice) ? 1 : 0;
        if (prev_data.rightOutPath.includes(tokenDict["1"])) {
            data.tokenShown = 1;
        } else if (prev_data.rightOutPath.includes(tokenDict["2"])) {
            data.tokenShown = 2;
        } else if (prev_data.rightOutPath.includes(tokenDict["3"])) {
            data.tokenShown = 3;
        }
        data.isGoal = (prev_data.goalToken == data.tokenShown) ? 1 : 0;
    }
};

var play_break = {
    type: "html-keyboard-response",
    choices: [choice_keys.space],
    stimulus:
        function () {
            // let outcomes = jsPsych.data.get().filter([{label: "left_outcome"}, {label: "right_outcome"}]).select('currOutcome');
            htmlstr = "<head><style> body {background-color: black;} </style></head>" + //'<head><link rel="alternate stylesheet" href="/static/css/custom.css" type="text/css" /></head>' +
                '<body><div class="centered whiteText"><p>' +
                '  Time for a short break.<br /><br />' +
                // "  You've earned a total of " + outcomes.sum() + " points so far.<br /><br />" +
                '  Press the spacebar when you\'re ready to continue' +
                '</p></div></body>';
            return htmlstr;
        },
    response_ends_trial: true,
    trial_duration: null,
    data: {label: "task_break"},
};

var done = {
    type: 'html-keyboard-response',
    choices: [choice_keys.space],
    response_ends_trial: true,
    stimulus: function () {
        let outcomes = jsPsych.data.get().filter([{label: "left_outcome"}, {label: "right_outcome"}]).select('currOutcome');
        score = outcomes.sum();
        let htmlstr = "<head><style> body {background-color: black;} </style></head>" + //'<head><link rel="alternate stylesheet" href="/static/css/custom.css" type="text/css" /></head>' +
            '<body><div class="centered whiteText"><p>' +
            '  You\'re done.<br /><br />' +
            '  You earned a total of ' + score + ' points.<br /><br />' +
            '  Press the spacebar to continue.' +
            '</p></div></body>';
        return htmlstr
    },
    data: {
        label: "task_done",
        taskname: "Watch Me",
    },
    on_finish: function(data) {
        let outcomes = jsPsych.data.get().filter([{label: "left_outcome"}, {label: "right_outcome"}]).select('currOutcome');
        score = outcomes.sum();
    }
};

var iti = {
    type: "html-keyboard-response",
    stimulus: function () {
        let htmlstr = "<head><style> body {background-color: black;} </style></head>" +
            '<body><div class="centered whiteText largeFont"><p>' +
            '  +  ' +
            '</p></div></body>';
        return htmlstr
    },
    choices: jsPsych.NO_KEYS,
    trial_duration: ITIdur,
    response_ends_trial: false,
    data: {label: "iti"},
};

var leftResp_ifNode = {
    timeline: [left_response, leftOutcome],
    conditional_function: function () {
        var prev_data = jsPsych.data.get().filter({label: "playOn"}).last(1).values()[0];
        var dummy_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        if (prev_data.key_press == null) {
            return false
        } else {
            return jsPsych.pluginAPI.compareKeys(prev_data.key_press, dummy_data.leftAllowKey)
        }
    }
};

var rightResp_ifNode = {
    timeline: [right_response, rightOutcome],
    conditional_function: function () {
        var prev_data = jsPsych.data.get().filter({label: "playOn"}).last(1).values()[0];
        var dummy_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        if (prev_data.key_press == null) {
            return false
        } else {
            return jsPsych.pluginAPI.compareKeys(prev_data.key_press, dummy_data.rightAllowKey)
        }
    }
};

var noResp_ifNode = {
    timeline: [no_response],
    conditional_function: function (data) {
        var prev_data = jsPsych.data.get().filter({label: "playOn"}).last(1).values()[0];
        return prev_data.key_press == null
    }
};


var observe_ifNode = {
    timeline: [observeOn, observeVid],
    conditional_function: function () {
        var prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        return prev_data.trialType == "Observe"
    }
};

var play_ifNode = {
    timeline: [playOn, leftResp_ifNode, rightResp_ifNode, noResp_ifNode],
    conditional_function: function () {
        var prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        return prev_data.trialType == "Play"
    }
};

var break_ifNode = {
    timeline: [play_break],
    conditional_function: function () {
        var prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        return (prev_data.blockNb==5 && prev_data.trialID==1)
    }
};

var done_ifNode = {
    timeline: [done],
    conditional_function: function (data) {
        return (jsPsych.data.get().filter([{label: "observeOn"}, {label: "playOn"}]).count() == obsvImit_Timeline_var.length + pract_obsvImit_Timeline_var.length)
    }
};

var obsvImit_trialProcedure = {
    timeline: [dummy, break_ifNode, conditionHeader, observe_ifNode, play_ifNode, iti, done_ifNode],
    timeline_variables: obsvImit_Timeline_var,
};
