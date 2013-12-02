

public class ft_svncli 
{

	/**
	 * @param args
	 */
	 /* XXX! Make sure that the project settings have the following:
	  * org.eclipse.jdt.core.compiler.codegen.inlineJsrBytecode=enabled
		org.eclipse.jdt.core.compiler.codegen.targetPlatform=1.6
		org.eclipse.jdt.core.compiler.codegen.unusedLocal=preserve
		org.eclipse.jdt.core.compiler.compliance=1.6
		org.eclipse.jdt.core.compiler.debug.lineNumber=generate
		org.eclipse.jdt.core.compiler.debug.localVariable=generate
		org.eclipse.jdt.core.compiler.debug.sourceFile=generate
		org.eclipse.jdt.core.compiler.problem.assertIdentifier=error
		org.eclipse.jdt.core.compiler.problem.enumIdentifier=error
		org.eclipse.jdt.core.compiler.source=1.6
		
		
		Otherwise this will not run on mac which only supports 1.6 out of the box

	  */
	public static void main(String[] args) 
	{
		// Make sure to set the headless property so that the app does not pop up in menu bar on mac
		System.setProperty("java.awt.headless", "true");
		 try
		 {
		 	org.tmatesoft.svn.cli.SVN.main(args);
		 }
		 catch(Exception e)
		 {
		 	System.out.println("Failed to launch SVN client :" + e.getLocalizedMessage());
		 }
	}

}
