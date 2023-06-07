// Preload instruction slides
var instruct_pages = [];
var Ninstruct = 25;

// pages from which key(s) other than left/right arrows are used for flipping slides
var exception_pages = {
    1: [choice_keys.space],
    3: [choice_keys.g, choice_keys.z],
    8: [null, choice_keys.z],
    9: [choice_keys.right, choice_keys.z],
    11: [null, choice_keys.z],
    12: [choice_keys.middle, choice_keys.z],
    17: [choice_keys.r, choice_keys.z],
    19: [choice_keys.two, choice_keys.z],
    20: [choice_keys.space, choice_keys.z],
};
let prev_next = [choice_keys.space, choice_keys.z];
var choiceKey_array = [];   // array holding valid keys for each instruction page
for (s = 0; s < Ninstruct; s++) {
    let slideNo = s + 1 + "";

    // add options from exception_pages for instructions with questions
    if (! Object.keys(exception_pages).includes(slideNo)) {
        choiceKey_array.push(prev_next);
    } else {choiceKey_array.push(exception_pages[slideNo])};

    if (slideNo < 10) {slideNo = "0"+slideNo}   // padding zero
    instruct_pages.push(instructDir + 'instr_' + slideNo + '.png');
}
console.log("Preloading OL instruction pages...");
preloadImages.push(...instruct_pages);
console.log("done");


function getObserveHTMLstr(left, middle, right, video) {
    let html = '<head><style> body {background-color: black;} </style></head>' +
        "<div id='observeContainer'>" +
        "    <div id='slotsContainer' class='whiteBorder'>" +
        "        <div class='slot'>" + left + "</div>" +
        "        <div class='slot'>" + middle + "</div>" +
        "        <div class='slot'>" + right + "</div>" +
        "    </div>" +
        "    <div id='videoContainer' class='whiteBorder'>" + video + "</div>" +
        "</div>";
    return html;
}

function getPlayHTMLstr(left, middle, right, string) {
    let html = '<head><style> body {background-color: black;} </style></head>' +
        "<div id='playContainer'>" +
        "    <div id='slotsContainer'>" +
        "        <div class='slot'>" + left + "</div>" +
        "        <div class='slot'>" + middle + "</div>" +
        "        <div class='slot'>" + right + "</div>" +
        "    </div>" +
        "    <div id='trialTypeContainer' class='centered whiteText largeFont'>" + string + "</div>" +
        "</div>";
    return html;
}
