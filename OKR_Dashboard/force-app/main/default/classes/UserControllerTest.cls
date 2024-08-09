@isTest
public class UserControllerTest {
    @TestSetup
    static void makeData(){
         // Generate a unique username by appending a timestamp
        String uniqueUserName = 'testuser@test.com' + System.currentTimeMillis();
        
        User testUser = new User(
            Alias = 'testusr',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'Europe/Riga',
            UserName = uniqueUserName
        );
        insert testUser;
    }

    @isTest
    static void testGetUsers() {
        Test.startTest();
        List<User> users = UserController.getUsers();
        Test.stopTest();
        System.assertNotEquals(0, users.size(), 'Expected at least one user');
    }
}