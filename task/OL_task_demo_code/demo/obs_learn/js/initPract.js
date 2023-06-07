
// Load in design from csv file
var pract_designMat = designArray.practice;

// These variables will change depending on the task
var pract_blockNb = Array(pract_designMat.length).fill(0);
var pract_blockID = Array(pract_designMat.length).fill(0);
var pract_trialID = Array(pract_designMat.length).fill(0);
var pract_trialType = Array(pract_designMat.length).fill(0);
var pract_video_nb =  [];
var pract_vidPaths =  [];
var pract_leftStimPaths = [];
var pract_midStimPaths = [];
var pract_rightStimPaths = [];
var pract_obsv_leftSelectPaths = [];
var pract_obsv_midSelectPaths = [];
var pract_obsv_rightSelectPaths = [];
var pract_play_LResp_leftStim = [];
var pract_play_LResp_midStim = [];
var pract_play_LResp_rightStim = [];
var pract_play_RResp_leftStim = [];
var pract_play_RResp_midStim = [];
var pract_play_RResp_rightStim = [];
var pract_leftOutPaths = [];
var pract_rightOutPaths = [];
var pract_goalToken = Array(pract_designMat.length).fill(0);
var pract_uncertainty = Array(pract_designMat.length).fill(0);
var pract_unavAct = Array(pract_designMat.length).fill(0);
var pract_corrAct = Array(pract_designMat.length).fill(0);
var pract_bestAct = Array(pract_designMat.length).fill(0);
var pract_vertOrd = Array(pract_designMat.length).fill(0);
var pract_horizOrd = Array(pract_designMat.length).fill(0);
var pract_leftOutVal = Array(pract_designMat.length).fill(0);
var pract_rightOutVal = Array(pract_designMat.length).fill(0);
var pract_availableKeys = Array(pract_designMat.length).fill(0);
var pract_isBreak = Array(pract_designMat.length).fill(0);
var pract_video_nb = Array(pract_designMat.length).fill(null);
var pract_allowable_keys = Array(pract_designMat.length).fill(null);
var pract_left_allowableKey = Array(pract_designMat.length).fill(null);
var pract_right_allowableKey = Array(pract_designMat.length).fill(null);

// Convert from JSON object to set of arrays
for (t = 0; t < pract_designMat.length; t++) {
    pract_blockNb[t] = Number(pract_designMat[t].runNb);
    pract_blockID[t] = Number(pract_designMat[t].runID);
    pract_trialID[t] = Number(pract_designMat[t].trialNb);
    pract_trialType[t] = (Number(pract_designMat[t].trType) == 1) ? "Observe" : "Play"; // trType=1 if observe trial, 2 if play
    pract_goalToken[t] = Number(pract_designMat[t].goalToken);
    pract_uncertainty[t] = Number(pract_designMat[t].uncertainty);
    pract_unavAct[t] = Number(pract_designMat[t].unavAct);
    pract_corrAct[t] = Number(pract_designMat[t].corrAct);
    pract_bestAct[t] = Number(pract_designMat[t].bestAct);
    pract_vertOrd[t] = Number(pract_designMat[t].vertOrd);
    pract_horizOrd[t] = Number(pract_designMat[t].horizOrd);
    let left_middle_right = [];
    switch(Number(pract_designMat[t].horizOrd)) {
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
    let U = (Number(pract_designMat[t].uncertainty) == 1) ? "_lbu_a.png" : "_hbu_a.png"; // uncertainty=1 if low, 2 if high uncertainty
    let VO = Number(pract_designMat[t].vertOrd);
    for (let i=0; i<left_middle_right.length; i++) {
        left_middle_right[i] = left_middle_right[i]+VO+U;
    }

    switch (Number(pract_designMat[t].unavAct)) {
        case 1:
            left_middle_right[0] = left_middle_right[0].replace('a', 'ua'); // unavailable version of stim
            pract_availableKeys[t] = "MR";
            break;
        case 2:
            left_middle_right[1] = left_middle_right[1].replace('a', 'ua'); // unavailable version of stim
            pract_availableKeys[t] = "LR";
            break;
        case 3:
            left_middle_right[2] = left_middle_right[2].replace('a', 'ua'); // unavailable version of stim
            pract_availableKeys[t] = "LM";
            break;
    }
    pract_leftStimPaths.push(stimDir + left_middle_right[0]);
    pract_midStimPaths.push(stimDir + left_middle_right[1]);
    pract_rightStimPaths.push(stimDir + left_middle_right[2]);

    if (pract_trialType[t] == "Observe") {
        let vidNum = getRandomIntInclusive(1, 5);
        pract_video_nb[t] = vidNum;
        let videoPath = vidNum + ".mp4";
        switch(Number(pract_designMat[t].corrAct)) {
            case 1:
                videoPath = "action_left_m" + videoPath;
                pract_obsv_leftSelectPaths.push(stimDir + left_middle_right[0].replace('a', 'p'));
                pract_obsv_midSelectPaths.push(stimDir + left_middle_right[1]);
                pract_obsv_rightSelectPaths.push(stimDir + left_middle_right[2]);
                break;
            case 2:
                videoPath = "action_down_m" + videoPath;
                pract_obsv_leftSelectPaths.push(stimDir + left_middle_right[0]);
                pract_obsv_midSelectPaths.push(stimDir + left_middle_right[1].replace('a', 'p'));
                pract_obsv_rightSelectPaths.push(stimDir + left_middle_right[2]);
                break;
            case 3:
                videoPath = "action_right_m" + videoPath;
                pract_obsv_leftSelectPaths.push(stimDir + left_middle_right[0]);
                pract_obsv_midSelectPaths.push(stimDir + left_middle_right[1]);
                pract_obsv_rightSelectPaths.push(stimDir + left_middle_right[2].replace('a', 'p'));
                break;
        }
        pract_vidPaths.push(vidDir + videoPath);
        pract_leftOutPaths.push(iti);
        pract_rightOutPaths.push(iti);
        pract_play_LResp_leftStim.push(iti);
        pract_play_LResp_midStim.push(iti);
        pract_play_LResp_rightStim.push(iti);
        pract_play_RResp_leftStim.push(iti);
        pract_play_RResp_midStim.push(iti);
        pract_play_RResp_rightStim.push(iti);

    } else if (pract_trialType[t] == "Play") {
        pract_vidPaths.push(vidDir + "empty.mp4");
        pract_obsv_leftSelectPaths.push(iti);
        pract_obsv_midSelectPaths.push(iti);
        pract_obsv_rightSelectPaths.push(iti);
        let outcomeIfLeft = (pract_designMat[t].tokenIfLeft == pract_designMat[t].goalToken) ? 10 : 0;
        let outcomeIfMid = (pract_designMat[t].tokenIfMid == pract_designMat[t].goalToken) ? 10 : 0;
        let outcomeIfRight = (pract_designMat[t].tokenIfRight == pract_designMat[t].goalToken) ? 10 : 0;
        switch(pract_availableKeys[t]) {
            case "LM":
                pract_play_LResp_leftStim.push(stimDir + left_middle_right[0].replace('a', 'p'));
                pract_play_LResp_midStim.push(stimDir + left_middle_right[1]);
                pract_play_LResp_rightStim.push(stimDir + left_middle_right[2]);
                pract_play_RResp_leftStim.push(stimDir + left_middle_right[0]);
                pract_play_RResp_midStim.push(stimDir + left_middle_right[1].replace('a', 'p'));
                pract_play_RResp_rightStim.push(stimDir + left_middle_right[2]);
                pract_leftOutPaths.push(stimDir + tokenDict[pract_designMat[t].tokenIfLeft]);
                pract_rightOutPaths.push(stimDir + tokenDict[pract_designMat[t].tokenIfMid]);
                pract_leftOutVal[t] = outcomeIfLeft;
                pract_rightOutVal[t] = outcomeIfMid;
                pract_allowable_keys[t] = [choice_keys.left, choice_keys.middle];
                pract_left_allowableKey[t] = choice_keys.left;
                pract_right_allowableKey[t] = choice_keys.middle;
                break;
            case "LR":
                pract_play_LResp_leftStim.push(stimDir + left_middle_right[0].replace('a', 'p'));
                pract_play_LResp_midStim.push(stimDir + left_middle_right[1]);
                pract_play_LResp_rightStim.push(stimDir + left_middle_right[2]);
                pract_play_RResp_leftStim.push(stimDir + left_middle_right[0]);
                pract_play_RResp_midStim.push(stimDir + left_middle_right[1]);
                pract_play_RResp_rightStim.push(stimDir + left_middle_right[2].replace('a', 'p'));
                pract_leftOutPaths.push(stimDir + tokenDict[pract_designMat[t].tokenIfLeft]);
                pract_rightOutPaths.push(stimDir + tokenDict[pract_designMat[t].tokenIfRight]);
                pract_leftOutVal[t] = outcomeIfLeft;
                pract_rightOutVal[t] = outcomeIfRight;
                pract_allowable_keys[t] = [choice_keys.left, choice_keys.right];
                pract_left_allowableKey[t] = choice_keys.left;
                pract_right_allowableKey[t] = choice_keys.right;
                break;
            case "MR":
                pract_play_LResp_leftStim.push(stimDir + left_middle_right[0]);
                pract_play_LResp_midStim.push(stimDir + left_middle_right[1].replace('a', 'p'));
                pract_play_LResp_rightStim.push(stimDir + left_middle_right[2]);
                pract_play_RResp_leftStim.push(stimDir + left_middle_right[0]);
                pract_play_RResp_midStim.push(stimDir + left_middle_right[1]);
                pract_play_RResp_rightStim.push(stimDir + left_middle_right[2].replace('a', 'p'));
                pract_leftOutPaths.push(stimDir + tokenDict[pract_designMat[t].tokenIfMid]);
                pract_rightOutPaths.push(stimDir + tokenDict[pract_designMat[t].tokenIfRight]);
                pract_leftOutVal[t] = outcomeIfMid;
                pract_rightOutVal[t] = outcomeIfRight;
                pract_allowable_keys[t] = [choice_keys.middle, choice_keys.right];
                pract_left_allowableKey[t] = choice_keys.middle;
                pract_right_allowableKey[t] = choice_keys.right;
                break;
        }
    }
    pract_isBreak[t] = Number(pract_designMat[t].isBreak);
}

pract_leftStimPaths.forEach(img => preloadSet.add(img));
pract_midStimPaths.forEach(img => preloadSet.add(img));
pract_rightStimPaths.forEach(img => preloadSet.add(img));
pract_obsv_leftSelectPaths.forEach(img => preloadSet.add(img));
pract_obsv_midSelectPaths.forEach(img => preloadSet.add(img));
pract_obsv_rightSelectPaths.forEach(img => preloadSet.add(img));
pract_play_LResp_leftStim.forEach(img => preloadSet.add(img));
pract_play_LResp_midStim.forEach(img => preloadSet.add(img));
pract_play_LResp_rightStim.forEach(img => preloadSet.add(img));
pract_play_RResp_leftStim.forEach(img => preloadSet.add(img));
pract_play_RResp_midStim.forEach(img => preloadSet.add(img));
pract_play_RResp_rightStim.forEach(img => preloadSet.add(img));
pract_leftOutPaths.forEach(img => preloadSet.add(img));
pract_rightOutPaths.forEach(img => preloadSet.add(img));
// Initialize list of preload images
preloadImages_OL = [...preloadSet];
preloadImages.push(...preloadImages_OL);

var numPractTrials = pract_designMat.length;
