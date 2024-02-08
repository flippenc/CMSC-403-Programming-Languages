public class FoodBankPatron
{
    public static void main(String[] args)
    {
        //create the bank, producer, and consumer
        //producer and consumer use the same bank
        FoodBank bank = new FoodBank();
        FoodProducer producer = new FoodProducer(bank);
        FoodConsumer consumer = new FoodConsumer(bank);

        //test code for multiple producers and consumers
        //for (int i = 0; i < 10; i++)
        //{
        //    (new FoodConsumer(bank)).start();
        //    (new FoodProducer(bank)).start();
        //}

        //start the producer and consumer threads
        producer.start();
        consumer.start();

    }
}
