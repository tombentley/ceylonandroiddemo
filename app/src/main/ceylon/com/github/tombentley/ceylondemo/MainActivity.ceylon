import android.os { Bundle, AsyncTask }
import android.app { ListActivity }
import android.widget { ArrayAdapter, ListAdapter, TextView, EditText}
import android.view { KeyEvent }
import android.view.inputmethod { EditorInfo }
import ceylon.interop.java { createJavaStringArray }
import java.lang { JString = String }
import android { AndroidR = R }
import ceylon.language.meta { modules }
import ceylon.uri { parseUri = parse }
import ceylon.http.client { httpGet = get }
import ceylon.json { parseJson = parse, JsonObject = Object, JsonArray = Array }
import ceylon.collection { MutableList, LinkedList }
import ceylon.random {randomize}

shared class MainActivity() extends ListActivity() {

    class LoadTitles() extends AsyncTask<String, Nothing, List<String>>() {
        shared actual List<String> doInBackground(String?* uris){
            value results = LinkedList<String>();
            for (uri in uris) {
                assert(exists uri);
                value request = httpGet(parseUri(uri));
                print("Getting ``uri``");
                value response = request.execute();
                print(response.contents);
                assert (is JsonArray titles = parseJson(response.contents));
                for (title in titles) {
                    assert (is String title);
                    results.add(title);
                }
            }
            return randomize(results);
        }
        shared actual void onPostExecute(List<String> result){
                print("Got result: ``result``");

            ListAdapter adapter = ArrayAdapter<JString>(outer, AndroidR.Layout.simple_list_item_1,
                createJavaStringArray(result));
            listAdapter = adapter;
        }
    }

    shared actual void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.Layout.activity_main);

        assert (is EditText editText = findViewById(R.Id.subjectText));
        editText.setOnEditorActionListener(object satisfies TextView.OnEditorActionListener {
            shared actual Boolean onEditorAction(TextView v, Integer actionId, KeyEvent evt) {
                Boolean handled;
                if (actionId == EditorInfo.imeActionGo) {
                    value url = "http://10.0.2.2:8084/titles/"+v.text.string;
                    print("Background fetching " + url);
                    LoadTitles().execute(url);
                    handled = true;
                } else {
                    print("Not handled");
                    handled = false;
                }
                return handled;
            }
        });

        ListAdapter adapter = ArrayAdapter<JString>(this, AndroidR.Layout.simple_list_item_1,
            createJavaStringArray(LinkedList<String>()));
        this.listAdapter = adapter;

    }
}