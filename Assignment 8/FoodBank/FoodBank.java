import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

public class FoodBank
{
    private int food;

    //bankLock is used to enforce mutual exclusion
    //checkFood is used to signal if there is enough food for the current consumer (prevents negative food)
    ReentrantLock bankLock = new ReentrantLock();
    Condition checkFood = bankLock.newCondition();

    public FoodBank()
    {
        food = 0;
    }

    //Deposit food in the bank
    public void giveFood(int f)
    {
        //lock the bank, deposit the food, use checkFood to signal all threads, then unlock the bank
        try
        {
            bankLock.lock();
            System.out.println("Depositing " + f + " items of food, the balance is now " + (food + f) + " items");
            food += f;
            checkFood.signalAll();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        finally
        {
            bankLock.unlock();
        }
    }

    //Take food from the bank
    public void takeFood(int f)
    {
        //lock the bank, if there is less food present than we are trying to take, wait for a signal
        //and then check again until there is enough food
        //if there is enough food, take it and unlock the bank
        try
        {
            bankLock.lock();
            while (f > food)
            {
                System.out.println("Waiting to get food");
                checkFood.await();
            }
            System.out.println("Taking " + f + " items of food, the balance is now " + (food - f) + " items");
            food -= f;
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        finally
        {
            bankLock.unlock();
        }
    }

}
