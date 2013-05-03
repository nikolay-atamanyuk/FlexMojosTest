/**
 * Created with IntelliJ IDEA.
 * User: a
 * Date: 03.05.13
 * Time: 14:33
 * To change this template use File | Settings | File Templates.
 */
package {
import flexunit.framework.Assert;

public class SimpleClassTest {
    public function SimpleClassTest() {
    }

    [Test]
    public function testReturnTrue():void {
        var testObj:SimpleClass=new SimpleClass();

        Assert.assertTrue("Expected true result", testObj.returnTrue());
    }
}
}
