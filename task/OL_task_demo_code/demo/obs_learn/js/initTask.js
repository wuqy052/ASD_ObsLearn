// Initialize the timeline
var timeline = [];
var preloadImages = [];

// Set up trial event durations
var conditionDur = 1000;
var observeOnDur = 2000;
var observeVidDur = 1500;

var ITIdur = 2000;
var cueDur = 4000;
var respDur = 1000;
var outDur = 2000;

// Set up clock
var d_start = new Date();
var t_start = 0;

// Specify image directories
var imageDir = "demo/obs_learn/images/";
var instructDir = imageDir + "instructions/";
var stimDir = imageDir + "stimuli/";
var vidDir = imageDir + "videos/";
// Define paths to general images
var topBox = stimDir + "top_box_observe.png";
var bottomBox = stimDir + "bottom_box_observe.png";
var iti = imageDir + "fix.png";

var tokenDict = {
    "1": "green.png",
    "2": "red.png",
    "3": "blue.png"
};

// look up table for available keys
//var choice_keys = {
//    "left": jsPsych.pluginAPI.convertKeyCharacterToKeyCode('leftarrow'),
//    "right": jsPsych.pluginAPI.convertKeyCharacterToKeyCode('rightarrow'),
//    "middle": jsPsych.pluginAPI.convertKeyCharacterToKeyCode('downarrow'),
//    "z": jsPsych.pluginAPI.convertKeyCharacterToKeyCode('z'),
//    "space": jsPsych.pluginAPI.convertKeyCharacterToKeyCode('space'),
//    "g": jsPsych.pluginAPI.convertKeyCharacterToKeyCode('g'),
//    "r": jsPsych.pluginAPI.convertKeyCharacterToKeyCode('r'),
//    "b": jsPsych.pluginAPI.convertKeyCharacterToKeyCode('b'),
//    "one": jsPsych.pluginAPI.convertKeyCharacterToKeyCode('1'),
//    "two": jsPsych.pluginAPI.convertKeyCharacterToKeyCode('2'),
//    "three": jsPsych.pluginAPI.convertKeyCharacterToKeyCode('3')
//};

var choice_keys = {
    "left": "ArrowLeft",
    "right": "ArrowRight",
    "middle": "ArrowDown",
    "z": "z",
    "space": " ",
    "g": "g",
    "r": "r",
    "b": "b",
    "one": "1",
    "two": "2",
    "three": "3"
};

// STORE DESIGN ID FOR EACH PARTICIPANT
// Load in design from csv file
var numDesigns = designArray.main.length;
var OL_designNo = getRandomIntInclusive(0, numDesigns - 1)
var designMat = designArray.main[OL_designNo];

// These variables will change depending on the task
var blockNb = Array(designMat.length).fill(0);
var blockID = Array(designMat.length).fill(0);
var trialID = Array(designMat.length).fill(0);
var trialType = Array(designMat.length).fill(0);
var vidPaths =  [];
var leftStimPaths = [];
var midStimPaths = [];
var rightStimPaths = [];
var obsv_leftSelectPaths = [];
var obsv_midSelectPaths = [];
var obsv_rightSelectPaths = [];
var play_LResp_leftStim = [];
var play_LResp_midStim = [];
var play_LResp_rightStim = [];
var play_RResp_leftStim = [];
var play_RResp_midStim = [];
var play_RResp_rightStim = [];
var leftOutPaths = [];
var rightOutPaths = [];
var goalToken = Array(designMat.length).fill(0);
var leftOutVal = Array(designMat.length).fill(0);
var rightOutVal = Array(designMat.length).fill(0);
var availableKeys = Array(designMat.length).fill(0);
var isBreak = Array(designMat.length).fill(0);
var video_nb = Array(designMat.length).fill(null);
var allowable_keys = Array(designMat.length).fill(null);
var left_allowableKey = Array(designMat.length).fill(null);
var right_allowableKey = Array(designMat.length).fill(null);
var uncertainty = Array(designMat.length).fill(0);
var unavAct = Array(designMat.length).fill(0);
var corrAct = Array(designMat.length).fill(0);
var bestAct = Array(designMat.length).fill(0);
var vertOrd = Array(designMat.length).fill(0);
var horizOrd = Array(designMat.length).fill(0);

// Convert from JSON object to set of arrays
for (t = 0; t < designMat.length; t++) {
    blockNb[t] = Number(designMat[t].runNb)
    blockID[t] = Number(designMat[t].runID);
    trialID[t] = Number(designMat[t].trialNb);
    trialType[t] = (Number(designMat[t].trType) == 1) ? "Observe" : "Play"; // trType=1 if observe trial, 2 if play
    goalToken[t] = Number(designMat[t].goalToken);
    uncertainty[t] = Number(designMat[t].uncertainty);
    unavAct[t] = Number(designMat[t].unavAct);
    corrAct[t] =  Number(designMat[t].corrAct);
    bestAct[t] = Number(designMat[t].bestAct);
    vertOrd[t] = Number(designMat[t].vertOrd);
    horizOrd[t] = Number(designMat[t].horizOrd);
    let left_middle_right = [];
    switch(Number(designMat[t].horizOrd)) {
        case 1:
            left_middle_right = ["G", "R", "B"];
            break;
        case 2:
            left_middle_right = ["R", "B", "G"];
            break;
        case 3:
            left_middle_right = ["B", "G", "R"];
            break;
    }
    let U = (Number(designMat[t].uncertainty) == 1) ? "_lbu_a.png" : "_hbu_a.png"; // uncertainty=1 if low, 2 if high uncertainty
    let VO = Number(designMat[t].vertOrd);
    for (let i=0; i<left_middle_right.length; i++) {
        left_middle_right[i] = left_middle_right[i]+VO+U;
    }

    switch (Number(designMat[t].unavAct)) {
        case 1:
            left_middle_right[0] = left_middle_right[0].replace('a', 'ua'); // unavailable version of stim
            availableKeys[t] = "MR";
            break;
        case 2:
            left_middle_right[1] = left_middle_right[1].replace('a', 'ua'); // unavailable version of stim
            availableKeys[t] = "LR";
            break;
        case 3:
            left_middle_right[2] = left_middle_right[2].replace('a', 'ua'); // unavailable version of stim
            availableKeys[t] = "LM";
            break;
    }
    leftStimPaths.push(stimDir + left_middle_right[0]);
    midStimPaths.push(stimDir + left_middle_right[1]);
    rightStimPaths.push(stimDir + left_middle_right[2]);

    if (trialType[t] == "Observe") {
        let vidNum = getRandomIntInclusive(1, 5);
        // let vidNum = getRandomIntInclusive(1, 1);
        video_nb[t] = vidNum;
        let videoPath = vidNum + ".mp4";
        switch(Number(designMat[t].corrAct)) {
            case 1:
                videoPath = "action_left_m" + videoPath;
                obsv_leftSelectPaths.push(stimDir + left_middle_right[0].replace('a', 'p'));
                obsv_midSelectPaths.push(stimDir + left_middle_right[1]);
                obsv_rightSelectPaths.push(stimDir + left_middle_right[2]);
                break;
            case 2:
                videoPath = "action_down_m" + videoPath;
                obsv_leftSelectPaths.push(stimDir + left_middle_right[0]);
                obsv_midSelectPaths.push(stimDir + left_middle_right[1].replace('a', 'p'));
                obsv_rightSelectPaths.push(stimDir + left_middle_right[2]);
                break;
            case 3:
                videoPath = "action_right_m" + videoPath;
                obsv_leftSelectPaths.push(stimDir + left_middle_right[0]);
                obsv_midSelectPaths.push(stimDir + left_middle_right[1]);
                obsv_rightSelectPaths.push(stimDir + left_middle_right[2].replace('a', 'p'));
                break;
        }
        vidPaths.push(vidDir + videoPath);
        leftOutPaths.push(iti);
        rightOutPaths.push(iti);
        play_LResp_leftStim.push(iti);
        play_LResp_midStim.push(iti);
        play_LResp_rightStim.push(iti);
        play_RResp_leftStim.push(iti);
        play_RResp_midStim.push(iti);
        play_RResp_rightStim.push(iti);

    } else if (trialType[t] == "Play") {
        vidPaths.push(vidDir + "empty.mp4");
        obsv_leftSelectPaths.push(iti);
        obsv_midSelectPaths.push(iti);
        obsv_rightSelectPaths.push(iti);
        let outcomeIfLeft = (designMat[t].tokenIfLeft == designMat[t].goalToken) ? 10 : 0;
        let outcomeIfMid = (designMat[t].tokenIfMid == designMat[t].goalToken) ? 10 : 0;
        let outcomeIfRight = (designMat[t].tokenIfRight == designMat[t].goalToken) ? 10 : 0;
        switch(availableKeys[t]) {
            case "LM":
                play_LResp_leftStim.push(stimDir + left_middle_right[0].replace('a', 'p'));
                play_LResp_midStim.push(stimDir + left_middle_right[1]);
                play_LResp_rightStim.push(stimDir + left_middle_right[2]);
                play_RResp_leftStim.push(stimDir + left_middle_right[0]);
                play_RResp_midStim.push(stimDir + left_middle_right[1].replace('a', 'p'));
                play_RResp_rightStim.push(stimDir + left_middle_right[2]);
                leftOutPaths.push(stimDir + tokenDict[designMat[t].tokenIfLeft]);
                rightOutPaths.push(stimDir + tokenDict[designMat[t].tokenIfMid]);
                leftOutVal[t] = outcomeIfLeft;
                rightOutVal[t] = outcomeIfMid;
                allowable_keys[t] = [choice_keys.left, choice_keys.middle];
                left_allowableKey[t] = choice_keys.left;
                right_allowableKey[t] = choice_keys.middle;
                break;
            case "LR":
                play_LResp_leftStim.push(stimDir + left_middle_right[0].replace('a', 'p'));
                play_LResp_midStim.push(stimDir + left_middle_right[1]);
                play_LResp_rightStim.push(stimDir + left_middle_right[2]);
                play_RResp_leftStim.push(stimDir + left_middle_right[0]);
                play_RResp_midStim.push(stimDir + left_middle_right[1]);
                play_RResp_rightStim.push(stimDir + left_middle_right[2].replace('a', 'p'));
                leftOutPaths.push(stimDir + tokenDict[designMat[t].tokenIfLeft]);
                rightOutPaths.push(stimDir + tokenDict[designMat[t].tokenIfRight]);
                leftOutVal[t] = outcomeIfLeft;
                rightOutVal[t] = outcomeIfRight;
                allowable_keys[t] = [choice_keys.left, choice_keys.right];
                left_allowableKey[t] = choice_keys.left;
                right_allowableKey[t] = choice_keys.right;
                break;
            case "MR":
                play_LResp_leftStim.push(stimDir + left_middle_right[0]);
                play_LResp_midStim.push(stimDir + left_middle_right[1].replace('a', 'p'));
                play_LResp_rightStim.push(stimDir + left_middle_right[2]);
                play_RResp_leftStim.push(stimDir + left_middle_right[0]);
                play_RResp_midStim.push(stimDir + left_middle_right[1]);
                play_RResp_rightStim.push(stimDir + left_middle_right[2].replace('a', 'p'));
                leftOutPaths.push(stimDir + tokenDict[designMat[t].tokenIfMid]);
                rightOutPaths.push(stimDir + tokenDict[designMat[t].tokenIfRight]);
                leftOutVal[t] = outcomeIfMid;
                rightOutVal[t] = outcomeIfRight;
                allowable_keys[t] = [choice_keys.middle, choice_keys.right];
                left_allowableKey[t] = choice_keys.middle;
                right_allowableKey[t] = choice_keys.right;
                break;
        }
    }
    isBreak[t] = Number(designMat[t].isBreak);
}

let preloadSet = new Set();
leftStimPaths.forEach(img => preloadSet.add(img));
midStimPaths.forEach(img => preloadSet.add(img));
rightStimPaths.forEach(img => preloadSet.add(img));
obsv_leftSelectPaths.forEach(img => preloadSet.add(img));
obsv_midSelectPaths.forEach(img => preloadSet.add(img));
obsv_rightSelectPaths.forEach(img => preloadSet.add(img));
play_LResp_leftStim.forEach(img => preloadSet.add(img));
play_LResp_midStim.forEach(img => preloadSet.add(img));
play_LResp_rightStim.forEach(img => preloadSet.add(img));
play_RResp_leftStim.forEach(img => preloadSet.add(img));
play_RResp_midStim.forEach(img => preloadSet.add(img));
play_RResp_rightStim.forEach(img => preloadSet.add(img));
leftOutPaths.forEach(img => preloadSet.add(img));
rightOutPaths.forEach(img => preloadSet.add(img));

// Preload the end of task slide
var task_end = imageDir + "task_end.png";
preloadSet.add(task_end);

// Initialize task parameters
var numBlocks = blockID.filter(onlyUnique).length;
var numBlockTrials = Math.max.apply(Math, trialID);
var numTotalTrials = designMat.length;
