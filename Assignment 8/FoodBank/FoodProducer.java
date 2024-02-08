public class FoodProducer extends Thread
{
    private FoodBank bank;

    public FoodProducer(FoodBank b)
    {
        bank = b;
    }

    @Override
    //The producer will add food to the bank every 100ms
    public void run()
    {
        while (true)
        {
            //add 1-100 food to the bank
            int toAdd = (int)( (Math.random()*100) + 1);
            bank.giveFood( toAdd );

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
