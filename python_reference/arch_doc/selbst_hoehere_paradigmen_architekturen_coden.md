
# Morphismus
1. Wenn ich einen Morphismus programmiere, dann ist das doch nichts weiteres, als eine Code-Transformation, bei der die Struktur nicht verloren geht

Ja, aber für die Kategorie!
Daher darf auch Struktur zerstört werden, wenn sie nicht zur Kategorie gehört.
-> ja! gut.

Beispiel:
int -> float durch float(x) ist ein Morphismus, wenn die betrachtete Struktur (z. B. Ordnung oder Addition) erhalten bleibt.

2. Ich könnte danach noch überprüfen (lassen) welche Eigenschaft oder Struktur erhalten bleibt oder verloren geht.

ja: Für transpilierung besonders gut.

3. Operatoren Morphismen Assoziativgesetzt heißt wie Addition Multiplikation und nicht Division (reicht für mich zum Verständnis).
4. Warum? Dafür: Es spielt keine Rolle, wie du eine Kette von Morphismen klammerst: (transpile ∘ optimize) ∘ parse = transpile ∘ (optimize ∘ parse).
5. Ohne Assoziativität müsstest du immer angeben, wie geklammert wird. Das wäre äußerst unpraktisch.

# Topologie
1. Und eine Topologie ist als Programmierung im einfachsten minimalfall nur, dass Codestruktur zusammen gehört.
1. 1. Und die Art der Verbundenheit und Nähe als Programmierinformation beliebiger Art.
1. 2. Und das Wie und Inwiefern, also die Art der Verbundenheit: z.B. bloße Nachbarschaft oder interagieren oder oder.
1. Nein: Also eine beliebige Gruppierung von Programmierdingen ist bereits damit eine Topologie.
Was fehlt bei einer bloßen Gruppierung von Programmierdingen, dass es eine Topologie ist? Irgendwelche irgendwelche Art von Nachbarschaftsbeschreibungen, dass diese Dinge auch wirklich zusammen gehören?
2. Eine Gruppierung ist eine Sammlung von Elementen.
Eine Topologie ist eine Gruppierung plus eine Definition von Nachbarschaft oder Zusammenhang.
3. Die Definition des zusammenhangs ist ja ein wie und ein inwiefern. Das lässt sich ja dann auch nachträglich überprüfen, was wieder gut für transpilierung ist.

# Kategorie
1. fast: und eine Kategorie ist im minimalen Programmierfall nur die Operatoren und die Objekte dazu.
1. 1. Operationen sind genauer Morphismen. Das bedeutet etwas drittes muss dazu: Kompositionsregeln.
2. Operatoren Morphismen Assoziativgesetzt heißt wie Addition Multiplikation und nicht Division (reicht für mich zum Verständnis).
3. Warum? Dafür: Es spielt keine Rolle, wie du eine Kette von Morphismen klammerst: (transpile ∘ optimize) ∘ parse = transpile ∘ (optimize ∘ parse).
4. Ohne Assoziativität müsstest du immer angeben, wie geklammert wird. Das wäre äußerst unpraktisch.
Wenn ich also bei der Kategorie nachträglich dazu schreibe, was zur Struktur gehört und was nicht, kann ich mit dieser Beschreibung nachträglich genau das überprüfen und habe somit damit eine Strukturüberprüfung, was günstig für die Transpilierung ist, aber nur bei umfangreichen Dingen, denn nur da verschluckt und vergisst die KI etwas beim Transpilieren.
5. Das ist einer der Gründe, warum Kategorien so elegant sind: Viele kleine Schritte können zu einem einzigen Morphismus zusammengefasst werden.
6. und eine Kategorie entspricht sozusagen einer Architektur

# Funktoren

1. Funktor transformiert gesamte Kategorie, nicht nur Objekte. 
2. Eine ganze Softwarearchitektur wird in eine andere Softwarearchitektur übersetzt, wobei alle erlaubten Transformationen erhalten bleiben.
3. Nach jedem Funktor könntest du automatisch prüfen:
✓ alle Objekte übertragen
✓ alle Morphismen übertragen
✓ alle Kompositionen erhalten
4. Für also dass die Tabelle für mehrere Ausgabeformate wiederverwendbar ist. Dafür beispielsweise Funktoren. Mehrere Ausgabeformate pro Tabelle entspricht deren Softwarearchitektur. Das ist praktisch die Überführung in eine andere Architektur. 
5. und die Datenbank kann genau diese Architekturen speichern, die ich mit den Funktoren nur kombinieren brauche, ohne dass die neu erstellte Tabelle oder deren Ausgabevariante gespeichert werden braucht.

# universelle Eigenschaft

1. fast: Eine universelle Eigenschaft ist im Wesentlichen die Faktorisierung, wenn ich danach weg lasse, dass der Strukturerhalt bestehen bleibt. Struktur die nicht zur Kategorie gehört, darf weg kommen. Die Universalkonstruktion ist die Faktorisierung. Faktoren sind Programmierdinge und was der Multiplikation entspricht sind die Morphismen.
2. Faktorisierung muss eindeutig sein: Wenn es eine Faktorisierung gibt, dann gibt es genau einen Morphismus, der sie möglich macht.
2. 1. Warum ist das so mächtig: Weil dadurch Konstruktionen kanonisch werden.
Dadurch brauchst du keine Implementierungsdetails mehr.
3. Nein, nicht ganz anderes: und aus diesem einen morphismus der die eindeutigkeit ist, kann ich dazwischen ein beliebiges graph netz mit beliebigem umfang und vernetztheit und kompliziertheit haben aus anderen morphismen und das zusammen meint die eindeutigkeit
3. 1. ahh also nicht einen morphismus und dazwischen beliebig, sondern dazwischen beliebig und einen zurück. Das war mein Denkfehler. Es ist übrigens kein "zurück" im Sinne einer Umkehrabbildung.
4. Vorteil: Dadurch kannst du die Architektur intern weiterentwickeln, ohne die mathematische Beschreibung der Gesamttransformation ändern zu müssen: universelle Tabellenkonstruktion und beliebige austauschbare Ausgabeformate wie html bbcode.
5. Die Mächtigkeit kommt daher, dass jede passende Abbildung über dasselbe Objekt faktorisiert. Weil der zentrale Vermittler die universelle Eigenschaft ist. Eine komplizierte Menge von Beziehungen wird auf einen gemeinsamen Vermittler zurückgeführt.
6. Komposition entspricht der Hintereinanderausführung.
7. Komplexität wird drastisch reduziert. Ich hatte das mit Generics Templates gemacht eine Tabelle in einem Rutsch in html shell bbcode verschieden auszugeben. Universelle Eigenschaften sind besser, modularer, etc.
8. Ja. Wie jetzt? Also doch keinen Morphismus bis ganz auf zurück sondern, kurz vor zurück, reicht auch als das was mit eindeutigkeit gemeint ist? Weil die Struktur erhalten bleibt? Und zwar die Struktur die gemeint ist und nicht die die nicht dazu gehört: Also die Struktur einer Kategorie.
8. 1. Begründung: Die universelle Eigenschaft fordert keine Umkehrabbildung und keinen Rückweg.
Es gibt genau einen Morphismus zu (oder von, je nach Konstruktion) dem universellen Objekt, sodass das gesamte Diagramm kommutiert: nicht mit kommutativ verwechseln, sondern: Alle Wege mit demselben Start- und Zielobjekt liefern dieselbe Komposition.
Kommutieren bedeutet, dass verschiedene Wege durch meine Softwarearchitektur hinsichtlich der Struktur der Kategorie zum gleichen Ergebnis führen.
8. 2. Die universelle Eigenschaft sagt nicht, dass es einen Rückweg gibt. Sie sagt, dass es genau einen Vermittlungsmorphismus gibt, der bezüglich der betrachteten Kategorie die gewünschte Struktur erhält und dadurch das Diagramm kommutativ macht.
8. 3. Alle Wege mit demselben Start- und Zielobjekt liefern dieselbe Komposition. und das ist besonders mächtig, weil man dann die Faktorisierung dadurch universell hat.



Faktorisierung

f=h∘g
sind die Faktoren nicht die Objekte, sondern die Morphismen:

g ist ein Faktor,
h ist ein Faktor.
Dann gilt

transpile = optimize ∘ parse

Die Faktoren sind

parse
optimize

3. Ja: Faktorisierung: Multiplikation entspricht Komposition: Hintereinanderausführung.
