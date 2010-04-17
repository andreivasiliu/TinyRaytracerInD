module sceneparser.general.SceneLoaderException;

class SceneLoaderException: Exception
{
    public this(char[] msg, Exception next = null)
    {
        super(msg, next);
    }
}
