import java.util.Arrays;
import java.util.Collections;
import java.util.Random;
import processing.sound.*;


String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 166; //you will need to look up the DPI or PPI of your device to make sure you get the right scale. Or play around with this value.
final float sizeOfInputArea = DPIofYourDeviceScreen * 1; //aka, 1.0 inches square!
PImage watch;
PImage finger;


String[] labels = new String[] {"ABC","DEF","GHI","JKL","MNO","PQR","STU","VWX","YZ"};
int selecting = - 1;

SoundFile[][] letter_sound_files;
SoundFile a_sound;
SoundFile b_sound;
SoundFile c_sound;
SoundFile d_sound;
SoundFile e_sound;
SoundFile f_sound;
SoundFile g_sound;
SoundFile h_sound;
SoundFile i_sound;
SoundFile j_sound;
SoundFile k_sound;
SoundFile l_sound;
SoundFile m_sound;
SoundFile n_sound;
SoundFile o_sound;
SoundFile p_sound;
SoundFile q_sound;
SoundFile r_sound;
SoundFile s_sound;
SoundFile t_sound;
SoundFile u_sound;
SoundFile v_sound;
SoundFile w_sound;
SoundFile x_sound;
SoundFile y_sound;
SoundFile z_sound;
SoundFile space_file;
SoundFile delete_file;
int prevSelecting = - 1;
int prevButton = - 1;

//0-abc,  1-def,  2-ghi,  3-jkl,  4-mno,  5-pqrs,  6-tuv, 7-wxyz

//You can modify anything in here. This is just a basic implementation.
void setup()
{
    //noCursor();
    watch = loadImage("watchhand3smaller.png");
    //finger = loadImage("pngeggSmaller.png"); //not using this
    phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
    Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
    //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing

    orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
    size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
    textFont(createFont("Arial", 20)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
    noStroke(); //my code doesn't use any strokes

    a_sound = new SoundFile(this, "A.mp3");
    b_sound = new SoundFile(this, "B.mp3");
    c_sound = new SoundFile(this, "C.mp3");
    d_sound = new SoundFile(this, "D.mp3");
    e_sound = new SoundFile(this, "E.mp3");
    f_sound = new SoundFile(this, "F.mp3");
    g_sound = new SoundFile(this, "G.mp3");
    h_sound = new SoundFile(this, "H.mp3");
    i_sound = new SoundFile(this, "I.mp3");
    j_sound = new SoundFile(this, "J.mp3");
    k_sound = new SoundFile(this, "K.mp3");
    l_sound = new SoundFile(this, "L.mp3");
    m_sound = new SoundFile(this, "M.mp3");
    n_sound = new SoundFile(this, "N.mp3");
    o_sound = new SoundFile(this, "O.mp3");
    p_sound = new SoundFile(this, "P.mp3");
    q_sound = new SoundFile(this, "Q.mp3");
    r_sound = new SoundFile(this, "R.mp3");
    s_sound = new SoundFile(this, "S.mp3");
    t_sound = new SoundFile(this, "T.mp3");
    u_sound = new SoundFile(this, "U.mp3");
    v_sound = new SoundFile(this, "V.mp3");
    w_sound = new SoundFile(this, "W.mp3");
    x_sound = new SoundFile(this, "X.mp3");
    y_sound = new SoundFile(this, "Y.mp3");
    z_sound = new SoundFile(this, "Z.mp3");
    space_file = new SoundFile(this, "S.mp3");
    delete_file = new SoundFile(this, "D.mp3");
    letter_sound_files = new SoundFile[][] {
        {a_sound,
            b_sound,
            c_sound,} ,
        {d_sound,
            e_sound,
            f_sound,} ,
        {g_sound,
            h_sound,
            i_sound,} ,
        {j_sound,
            k_sound,
            l_sound,} ,
        {m_sound,
            n_sound,
            o_sound,} ,
        {p_sound,
            q_sound,
            r_sound,} ,
        {s_sound,
            t_sound,
            u_sound,} ,
        {v_sound,
            w_sound,
            x_sound,} ,
        {y_sound,y_sound,
        z_sound}
    };
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
    background(255); //clear background

    //check to see if the user finished. You can't change the score computation.
    if (finishTime!= 0)
        {
        fill(0);
        textAlign(CENTER);
        text("Trials complete!",400,200); //output
        text("Total time taken: " + (finishTime - startTime),400,220); //output
        text("Total letters entered: " + lettersEnteredTotal,400,240); //output
        text("Total letters expected: " + lettersExpectedTotal,400,260); //output
        text("Total errors entered: " + errorsTotal,400,280); //output
        float wpm = (lettersEnteredTotal / 5.0f) / ((finishTime - startTime) / 60000f); //FYI - 60K is number of milliseconds in minute
        text("Raw WPM: " + wpm,400,300); //output
        float freebieErrors = lettersExpectedTotal *.05; //no penalty if errors are under 5% of chars
        text("Freebie errors: " + nf(freebieErrors,1,3),400,320); //output
        float penalty = max(errorsTotal - freebieErrors, 0) * .5f;
        text("Penalty: " + penalty,400,340);
        text("WPM w/ penalty: " + (wpm - penalty),400,360); //yes, minus, because higher WPM is better
        return;
    }

    drawWatch(); //draw watch background
    fill(200);
    noStroke();
    rect(width / 2 - sizeOfInputArea / 2, height / 2 - sizeOfInputArea / 2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"


    if (startTime == 0 & !mousePressed)
        {
        fill(128);
        textAlign(CENTER);
        text("Click to start time!", 280, 150); //display this messsage until the user clicks!
    }

    if (startTime == 0 & mousePressed)
        {
        nextTrial(); //start the trials!
    }

    if (startTime!= 0)
        {
        //feel free to change the size and position of the target/entered phrases and next button
        textAlign(LEFT); //align the text left
        fill(128);
        textSize(12);
        text("Phrase " + (currTrialNum + 1) + " of " + totalTrialNum, 70, 50); //draw the trial count
        fill(128);
        text("Target:   " + currentPhrase, 70, 100); //draw the target string
        text("Entered:  " + currentTyped + "|", 70, 140); //draw what the user has entered thus far

        //draw very basic next button
        fill(255, 0, 0);
        rect(600, 600, 200, 200); //draw next button
        fill(255);
        text("NEXT > ", 650, 650); //draw next label

        //example design draw code

        drawDesign();
    }


    //drawFinger(); //no longer needed as we'll be deploying to an actual touschreen device
}





void drawDesign() {
    //sizeOfInputArea
    //ABC Button
    if (selecting ==- 1) {
        drawButtons();
        return;
    }
    if (selecting == 0) {//ABC top left
        fill(220);
        drawButton(selecting, labels[selecting]);
        fill(255);
        drawButton(0, labels[selecting].substring(0,1));
        fill(255);
        drawButton(1, labels[selecting].substring(1,2));
        fill(255);
        drawButton(2, labels[selecting].substring(2,3));

    }

    if (selecting == 1) {//DEF   top middle
        fill(220);
        drawButton(selecting, labels[selecting]);
        fill(255);
        drawButton(0, labels[selecting].substring(0,1));
        fill(255);
        drawButton(1, labels[selecting].substring(1,2));
        fill(255);
        drawButton(2, labels[selecting].substring(2,3));
    }

    if (selecting == 2) {//GHI   top right
        fill(220);
        drawButton(selecting, labels[selecting]);
        fill(255);
        drawButton(0, labels[selecting].substring(0,1));
        fill(255);
        drawButton(1, labels[selecting].substring(1,2));
        fill(255);
        drawButton(2, labels[selecting].substring(2,3));
    }

    if (selecting == 3) {//JKL   mid left
        fill(220);
        drawButton(selecting, labels[selecting]);
        fill(255);
        drawButton(3, labels[selecting].substring(0,1));
        fill(255);
        drawButton(4, labels[selecting].substring(1,2));
        fill(255);
        drawButton(5, labels[selecting].substring(2,3));
    }

    if (selecting == 4) {//MNO  middy
        fill(220);
        drawButton(selecting, labels[selecting]);
        fill(255);
        drawButton(3, labels[selecting].substring(0,1));
        fill(255);
        drawButton(4, labels[selecting].substring(1,2));
        fill(255);
        drawButton(5, labels[selecting].substring(2,3));
        drawSpace(2);
    }

    if (selecting == 5) {//PQR  mid right
        fill(220);
        drawButton(selecting, labels[selecting]);
        fill(255);
        drawButton(3, labels[selecting].substring(0,1));
        fill(255);
        drawButton(4, labels[selecting].substring(1,2));
        fill(255);
        drawButton(5, labels[selecting].substring(2,3));
    }

    if (selecting == 6) {//STU  bottom left
        fill(220);
        drawButton(selecting, labels[selecting]);
        fill(255);
        drawButton(6, labels[selecting].substring(0,1));
        fill(255);
        drawButton(7, labels[selecting].substring(1,2));
        fill(255);
        drawButton(8, labels[selecting].substring(2,3));
        fill(255);
    }

    if (selecting == 7) {//TUV  bottom middle
        fill(220);
        drawButton(selecting, labels[selecting]);
        fill(255);
        drawButton(6, labels[selecting].substring(0,1));
        fill(255);
        drawButton(7, labels[selecting].substring(1,2));
        fill(255);
        drawButton(8, labels[selecting].substring(2,3));
        fill(255);
    }

    if (selecting == 8) {//YZdel  bottom right
        fill(220);
        drawButton(selecting,labels[selecting]);
        fill(255);
        drawButton(7, labels[selecting].substring(0,1));
        fill(255);
        drawButton(8, labels[selecting].substring(1,2));
        fill(255);
        drawButton(5, "DEL");
    }
}


void drawButtons() {
    //Top-Left
    float x = width / 2 - sizeOfInputArea / 2;
    float y = height / 2 - sizeOfInputArea / 2;
    float inc = sizeOfInputArea / 3;
    stroke(0); strokeWeight(2);
    for (int i = 0; i < 9; i++) {
        fill(220); textSize(12);
        drawButton(i,labels[i]);
    }
}

void drawButton(int bInd, String label) {
    int xInd = bInd % 3;
    int yInd = bInd / 3;
    float inc = (float)sizeOfInputArea / 3;

    float x = width / 2 - sizeOfInputArea / 2 + xInd * inc;
    float y = height / 2 - sizeOfInputArea / 2 + yInd * inc;
    strokeWeight(1); stroke(0);
    if (mousePressed && getMouseOver() == bInd && startTime > 0) {
        fill(0,255,0);
        println("highlighted!");
        playLetterSound(xInd, bInd);
    }
    square(x,y,inc);

    textAlign(CENTER);
    fill(0);
    if (label == "SPACE") textSize(10);
    else textSize(12);
    text(label, x + inc / 2, y + inc / 2);
    if (bInd == 4 && !mousePressed) {
        text("' _ '",x + inc / 2, y + 0.9 * inc);
    }
    if (bInd == 8 && !mousePressed) {
        textSize(9);
        text("DEL", x + inc / 2, y + 0.2 * inc);
    }
    //line(x+12,y+inc/2+3,x+24,y+inc/2+3);
}

void playLetterSound(int x, int bInd) {
    System.out.println(selecting + ", " + x);
    System.out.println(prevSelecting);
    if (selecting >= 0 && x < letter_sound_files[selecting].length && !letter_sound_files[selecting][x].isPlaying()) {
        letter_sound_files[selecting][x].play();
    }

    // if (!(prevSelecting == selecting && prevButton == x)) {
    //     if (prevSelecting == - 1) {
    //         // space_file.play();
    //     } else if (prevSelecting == - 2) {
    //         // delete_file.play();
    //     } else {
    //         letter_sound_files[selecting][x].play();
    //     }
    //     prevButton = x;
    //     prevSelecting = selecting;
    // }
}

void drawSpace(int third) {
    fill(255);
    float inc = (float)sizeOfInputArea / 3;
    float x = width / 2 - sizeOfInputArea / 2;
    float y = height / 2 - sizeOfInputArea / 2 + third * inc;
    if (mousePressed && getMouseOver()>= 6 && getMouseOver()<= 8) fill(0,255,0);
    rect(x,y,3 * inc,inc);
    fill(0);

    text("SPACE", x + 1.5 * inc, y + inc / 2);
}

//my terrible implementation you can entirely replace
void mousePressed()
{
    if (startTime == 0) return;
    selecting = getMouseOver();
    //You are allowed to have a next button outside the 1" area
    if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
        {
        nextTrial(); //if so, advance to next trial
    }
}

void mouseReleased() {
    prevSelecting = - 1;
    if (selecting ==- 1) return;
    command(selecting,getMouseOver());
    selecting = - 1;
}

void command(int prs, int rls) {
    String ip = "";
    if (prs == 0) {
        if (rls == 0) ip = "a";
        else if (rls == 1) ip = "b";
        else if (rls == 2) ip = "c";
    }
    else if (prs == 1) {
        if (rls == 0) ip = "d";
        else if (rls == 1) ip = "e";
        else if (rls == 2) ip = "f";

    }
    else if (prs == 2) {
        if (rls == 0) ip = "g";
        else if (rls == 1) ip = "h";
        else if (rls == 2) ip = "i";
    }
    else if (prs == 3) {
        if (rls == 3) ip = "j";
        else if (rls == 4) ip = "k";
        else if (rls == 5) ip = "l";
    }
    else if (prs == 4) {
        if (rls == 3) ip = "m";
        else if (rls == 4) ip = "n";
        else if (rls == 5) ip = "o";
        else if (rls >= 6 && rls <= 8) ip = " ";
    }

    else if (prs == 5) {
        if (rls == 3) ip = "p";
        else if (rls == 4) ip = "q";
        else if (rls == 5) ip = "r";
    }
    else if (prs == 6) {
        if (rls == 6) ip = "s";
        else if (rls == 7) ip = "t";
        else if (rls == 8) ip = "u";
    }
    else if (prs == 7) {
        if (rls == 6) ip = "v";
        else if (rls == 7) ip = "w";
        else if (rls == 8) ip = "x";
    }
    else if (prs == 8) {
        if (rls == 7) ip = "y";
        else if (rls == 8) ip = "z";
        else if (rls == 5 && currentTyped.length()>0) {
            currentTyped = currentTyped.substring(0,currentTyped.length() - 1);
            return;
        }
    }

    currentTyped += ip;
}

int getMouseOver() {
    float x = mouseX - width / 2 + sizeOfInputArea / 2;
    float y = mouseY - height / 2 + sizeOfInputArea / 2;
    x = floor(x / ((float)sizeOfInputArea) * 3);
    y = floor(y / ((float)sizeOfInputArea) * 3);
    if (x < 0 || x > 2 || y < 0 || y > 2) return - 1;
    return(int)(y * 3 + x);
}


void nextTrial()
{
    if (currTrialNum >= totalTrialNum) //check to see if experiment is done
        return; //if so, just return

    if (startTime!= 0 && finishTime == 0) //in the middle of trials
        {
        System.out.println("==================");
        System.out.println("Phrase " + (currTrialNum + 1) + " of " + totalTrialNum); //output
        System.out.println("Target phrase: " + currentPhrase); //output
        System.out.println("Phrase length: " + currentPhrase.length()); //output
        System.out.println("User typed: " + currentTyped); //output
        System.out.println("User typed length: " + currentTyped.length()); //output
        System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
        System.out.println("Time taken on this trial: " + (millis() - lastTime)); //output
        System.out.println("Time taken since beginning: " + (millis() - startTime)); //output
        System.out.println("==================");
        lettersExpectedTotal +=currentPhrase.trim().length();
        lettersEnteredTotal +=currentTyped.trim().length();
        errorsTotal +=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
    }

    //probably shouldn't need to modify any of this output / penalty code.
    if (currTrialNum == totalTrialNum - 1) //check to see if experiment just finished
        {
        finishTime = millis();
        System.out.println("==================");
        System.out.println("Trials complete!"); //output
        System.out.println("Total time taken: " + (finishTime - startTime)); //output
        System.out.println("Total letters entered: " + lettersEnteredTotal); //output
        System.out.println("Total letters expected: " + lettersExpectedTotal); //output
        System.out.println("Total errors entered: " + errorsTotal); //output

        float wpm = (lettersEnteredTotal / 5.0f) / ((finishTime - startTime) / 60000f); //FYI - 60K is number of milliseconds in minute
        float freebieErrors = lettersExpectedTotal *.05; //no penalty if errors are under 5% of chars
        float penalty = max(errorsTotal - freebieErrors, 0) * .5f;

        System.out.println("Raw WPM: " + wpm); //output
        System.out.println("Freebie errors: " + freebieErrors); //output
        System.out.println("Penalty: " + penalty);
        System.out.println("WPM w/ penalty: " + (wpm - penalty)); //yes, minus, becuase higher WPM is better
        System.out.println("==================");

        currTrialNum++; //increment by one so this mesage only appears once when all trials are done
        return;
    }

    if (startTime == 0) //first trial starting now
        {
        System.out.println("Trials beginning! Starting timer..."); //output we're done
        startTime = millis(); //start the timer!
    }
    else
        currTrialNum++; //increment trial number

    lastTime = millis(); //record the time of when this trial ended
    currentTyped = ""; //clear what is currently typed preparing for next trial
    currentPhrase = phrases[currTrialNum]; // load the next phrase!
    //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//probably shouldn't touch this - should be same for all teams.
void drawWatch()
{
    float watchscale = DPIofYourDeviceScreen / 138.0; //normalizes the image size
    pushMatrix();
    translate(width / 2, height / 2);
    scale(watchscale);
    imageMode(CENTER);
    image(watch, 0, 0);
    popMatrix();
}

//probably shouldn't touch this - should be same for all teams.
void drawFinger()
{
    float fingerscale = DPIofYourDeviceScreen / 150f; //normalizes the image size
    pushMatrix();
    translate(mouseX, mouseY);
    scale(fingerscale);
    imageMode(CENTER);
    image(finger,52,341);
    if (mousePressed)
        fill(0);
    else
        fill(255);
    ellipse(0,0,5,5);

    popMatrix();
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
    return(mouseX > x && mouseX<x + w && mouseY>y && mouseY<y + h); //check to see if it is in button bounds
}


//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
    int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

    for (int i = 0; i <= phrase1.length(); i++)
        distance[i][0] = i;
    for (int j = 1; j <= phrase2.length(); j++)
        distance[0][j] = j;

    for (int i = 1; i <= phrase1.length(); i++)
        for (int j = 1; j <= phrase2.length(); j++)
            distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

    return distance[phrase1.length()][phrase2.length()];
}
