var isPract = 1;
var trial_nb = 0;

// Instrumental trials
// Create timeline variable
var pract_obsvImit_Timeline_var = [];
for (var trial = 0; trial < numPractTrials; trial++) {
    pract_obsvImit_Timeline_var.push({
        tv_vidPath: pract_vidPaths[trial],
        tv_leftStim: pract_leftStimPaths[trial],
        tv_midStim: pract_midStimPaths[trial],
        tv_rightStim: pract_rightStimPaths[trial],
        tv_obsv_leftSelect: pract_obsv_leftSelectPaths[trial],
        tv_obsv_midSelect: pract_obsv_midSelectPaths[trial],
        tv_obsv_rightSelect: pract_obsv_rightSelectPaths[trial],
        tv_play_LResp_leftStim: pract_play_LResp_leftStim[trial],
        tv_play_LResp_midStim: pract_play_LResp_midStim[trial],
        tv_play_LResp_rightStim: pract_play_LResp_rightStim[trial],
        tv_play_RResp_leftStim: pract_play_RResp_leftStim[trial],
        tv_play_RResp_midStim: pract_play_RResp_midStim[trial],
        tv_play_RResp_rightStim: pract_play_RResp_rightStim[trial],
        tv_goalToken: pract_goalToken[trial],
        tv_uncertainty: pract_uncertainty[trial],
        tv_unavAct: pract_unavAct[trial],
        tv_corrAct: pract_corrAct[trial],
        tv_bestAct: pract_bestAct[trial],
        tv_vertOrd: pract_vertOrd[trial],
        tv_horizOrd: pract_horizOrd[trial],
        tv_video_nb: pract_video_nb[trial],
        tv_leftOutVal: pract_leftOutVal[trial],
        tv_rightOutVal: pract_rightOutVal[trial],
        tv_leftOutPath: pract_leftOutPaths[trial],
        tv_rightOutPath: pract_rightOutPaths[trial],
        tv_allowable_keys: pract_allowable_keys[trial],
        tv_availableKeys: pract_availableKeys[trial],
        tv_leftAllowable: pract_left_allowableKey[trial],
        tv_rightAllowable: pract_right_allowableKey[trial],
        tv_blockNb: pract_blockNb[trial],
        tv_blockID: pract_blockID[trial],
        tv_trialID: pract_trialID[trial],
        tv_trialType: pract_trialType[trial],
        tv_isBreak: pract_isBreak[trial],
        tv_designNo: OL_designNo
    });
}

var pract_done = {
    type: 'html-keyboard-response',
    choices: [choice_keys.space],
    response_ends_trial: true,
    stimulus: "<head><style> body {background-color: black;} </style></head>" + //'<head><link rel="alternate stylesheet" href="/static/css/custom.css" type="text/css" /></head>' +
        '<body><div class="centered whiteText"><p>'+
        '  You\'re done with practice.<br /><br />'+
        '  Press the spacebar when you\'re ready to start playing.<br /><br />'+
        '</p></div></body>',
    data: {label: "pract_done"},
    on_finish: function(data) {
        isPract = 0;
        trial_nb = 0;
    },
};

// ifnode - conditional to determine whether mini-timeline is run
// ifnode must come after the events called in the mini-timeline
var pract_done_ifNode = {
    timeline: [pract_done],
    conditional_function: function (data) {
        var prev_data = jsPsych.data.get().filter({label: "dummy"}).last(1).values()[0];
        return (prev_data.blockNb==0 && prev_data.trialID==pract_obsvImit_Timeline_var.length)
    }
};

var obsvImit_practProcedure = {
    timeline: [dummy, conditionHeader, observe_ifNode, play_ifNode, iti, pract_done_ifNode],
    timeline_variables: pract_obsvImit_Timeline_var,
};
