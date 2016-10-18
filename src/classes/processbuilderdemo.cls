public class processbuilderdemo {
    @InvocableMethod
    public static void sendRequest(List<Id> kaId)
    {
       system.debug('kaid: '+kaId);
    }
}