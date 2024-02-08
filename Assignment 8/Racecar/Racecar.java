import javafx.application.Application;
import javafx.application.Platform;
import javafx.concurrent.Task;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.Pane;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.stage.Stage;

import static javafx.scene.control.Alert.AlertType.INFORMATION;

public class Racecar extends Application
{

    //flag to check if the race is going or not
    boolean raceStarted = false;

    //ImageViews of the cars
    ImageView car1View;
    ImageView car2View;
    ImageView car3View;

    //The threads that the cars run on
    Thread car1Race;
    Thread car2Race;
    Thread car3Race;

    //Start creates the stage and draws everything
    @Override
    public void start(Stage stage) throws Exception
    {
        Pane racePane = new Pane();

        //load the image of the car
        Image car = new Image("/sportive-car.png");

        //instantiate carview objects using the image and place them on the pane
        car1View = new ImageView(car);
        car1View.setX(10);
        car1View.setY(45);

        car2View = new ImageView(car);
        car2View.setX(10);
        car2View.setY(95);

        car3View = new ImageView(car);
        car3View.setX(10);
        car3View.setY(145);

        //create buttons with labels start, pause, reset
        Button start = new Button("Start");
        Button pause = new Button("Pause");
        Button reset = new Button("Reset");

        //put the buttons at the top of the screen
        start.relocate(100,10);
        pause.relocate(250,10);
        reset.relocate(400,10);

        //make the buttons call their respective methods when clicked
        start.setOnAction((event) -> startRace());
        pause.setOnAction((event) -> pauseRace());
        reset.setOnAction((event) -> resetRace());

        //The color shown in the example track has hex code CFCFCF
        Color trackColor = Color.web("0xCFCFCF");

        //Make tracks of length 420 and height 12
        //The car image size is 32x32 but the non-transparent part is 12x32
        Rectangle track1 = new Rectangle(420, 12, trackColor);
        Rectangle track2 = new Rectangle(420, 12, trackColor);
        Rectangle track3 = new Rectangle(420, 12, trackColor);

        //align the tracks to be right in front of the cars
        track1.setX(42);
        track1.setY(55);

        track2.setX(42);
        track2.setY(105);

        track3.setX(42);
        track3.setY(155);

        //add everything to the pane
        //add the tracks to the pane before the cars so the track is displayed behind the cars
        racePane.getChildren().addAll(track1,track2,track3);
        racePane.getChildren().addAll(car1View,car2View,car3View);
        racePane.getChildren().addAll(start, pause, reset);

        //set the scene for the stage
        Scene raceScene = new Scene(racePane, 500, 200);
        stage.setScene(raceScene);

        stage.setTitle("Richmond Raceway");
        stage.setResizable(false);

        stage.show();
    }

    //When the "start" button is pressed, the race starts
    //When a car passes over the end of the race, raceWinner is called which displays the winner
    public void startRace()
    {
        //if a race has ended and start is pressed, reset the cars and then start them
        //without this if statement, spamming the start button after a race ended can make
        //the cars go off of the track
        if (car1View.getX() >= 430 || car2View.getX() >= 430 || car3View.getX() >= 430)
        {
            resetRace();
            startRace();
        }

        //if race already started, don't do anything, otherwise start the race
        if (!raceStarted)
        {
            //start the race flag
            raceStarted = true;

            //each car has its own task: task1 for car1, task2 for car2, task3 for car3
            //these tasks are Void since they don't return anything - they call raceWinner if they win
            Task<Void> task1 = new Task<>()
            {
                @Override
                public Void call()
                {
                    while (raceStarted)
                    {
                        //if this car hasn't passed the finish line, go forward 0-10 pixels, then sleep for 50ms
                        if (car1View.getX() < 430)
                        {
                            int forward = (int)(Math.random()*11);
                            //runLater prevents issues with updating the GUI from a thread
                            Platform.runLater( () -> car1View.setX(car1View.getX() + forward) );
                            try
                            {
                                Thread.sleep(50);
                            }
                            catch (InterruptedException e)
                            {
                                e.printStackTrace();
                            }
                        }
                        //otherwise, the car is at or past the finish line, so stop the race and call the alert
                        //to display the winner
                        else
                        {
                            raceStarted = false;
                            Platform.runLater( () -> raceWinner(1) );
                        }
                    }
                    //since this is a Void object, return null
                    return null;
                }
            };

            Task<Void> task2 = new Task<>()
            {
                @Override
                public Void call()
                {
                    while (raceStarted)
                    {
                        if (car2View.getX() < 430)
                        {
                            int forward = (int)(Math.random()*11);
                            Platform.runLater( () -> car2View.setX(car2View.getX() + forward) );
                            try
                            {
                                Thread.sleep(50);
                            }
                            catch (InterruptedException e)
                            {
                                e.printStackTrace();
                            }
                        }
                        else
                        {
                            raceStarted = false;
                            Platform.runLater( () -> raceWinner(2) );
                        }
                    }
                    return null;
                }
            };

            Task<Void> task3 = new Task<>()
            {
                @Override
                public Void call()
                {
                    while (raceStarted)
                    {
                        if (car3View.getX() < 430)
                        {
                            int forward = (int)(Math.random()*11);
                            Platform.runLater( () -> car3View.setX(car3View.getX() + forward) );
                            try
                            {
                                Thread.sleep(50);
                            }
                            catch (InterruptedException e)
                            {
                                e.printStackTrace();
                            }
                        }
                        else
                        {
                            raceStarted = false;
                            Platform.runLater( () -> raceWinner(3) );
                        }
                    }
                    return null;
                }
            };

            //assign the threads to their tasks
            car1Race = new Thread(task1);
            car2Race = new Thread(task2);
            car3Race = new Thread(task3);

            //the example on the Task API page used setDaemon(true) to make it so the tasks won't prevent the VM
            //from exiting
            car1Race.setDaemon(true);
            car2Race.setDaemon(true);
            car3Race.setDaemon(true);

            //start the threads
            car1Race.start();
            car2Race.start();
            car3Race.start();
        }
    }

    //When "Pause" is pressed, the race is paused
    public void pauseRace()
    {
        //if race already paused, don't do anything, otherwise stop the race
        if (raceStarted)
        {
            raceStarted = false;
        }
    }

    //When "Reset" is pressed, the race is reset
    public void resetRace()
    {
        //stop the race and move the cars back to their initial positions
        raceStarted = false;
        car1View.setX(10);
        car2View.setX(10);
        car3View.setX(10);
    }

    //Method to display the winner of the race as an alert
    public void raceWinner(int car)
    {
        String winnerNumber;
        if (car == 1)
        {
            winnerNumber = "One";
        }
        else if (car == 2)
        {
            winnerNumber = "Two";
        }
        else
        {
            winnerNumber = "Three";
        }
        Alert winner = new Alert( INFORMATION, "Car "+winnerNumber+" Wins!");
        winner.show();
    }

    public static void main(String[] args)
    {
        launch(args);
    }
}
