public class FoodConsumer extends Thread
{
    private FoodBank bank;

    public FoodConsumer(FoodBank b)
    {
        bank = b;
    }

    @Override
    //The consumer will take food from the bank every 100ms
    public void run()
    {
        while(true)
        {
            //take 1-100 food from the bank
            int toTake = (int)( (Math.random()*100) + 1);
            bank.takeFood(toTake);

            //then sleep for 100ms
            try
            {
                sleep(100);
            }
            catch (InterruptedException e)
            {
                e.printStackTrace();
            }
        }
    }
}
