

Es gibt die 2 Ordner libs und reta_architecture.
Aus libs wurden viele Code Teile zu reta_architecture rüber gezogen.
Die höheren math Objekte wie Topologie sind größtenteils Stringlisten mit Gesetzen usw.
Validiert werden deren Vorhandensein am Ende sozusagen.
Topologien werden komponiert durch bloße Mengenvereinigungen einer Mengen.
Mein Quellcode wird einfach verbunden über imports in andere Klassen.
Das sieht dann so aus, wie als ob die Klasse nur aus kurzen kleinen Zuweisungen besteht.
Ich müsste noch schauen, wo das einzelne math Objekt wie Morphismus oder Topologie als einzelner Stringvergleich stattfindet, an der Stelle wo das dann als Objekt ist, denn es kann ja nicht sein, dass alles nur am Anfang gesamt-aufgelistet ist und dann am Ende alles zusammen gefunden wird, ob die Strings da sind, aber wahrscheinlich funktioniert das im Einzelnen ein wenig anders.
Gesetze existieren nur als strings und validierung passiert nur im Bereich von ja vorhanden alle vorhanden. Aber da muss noch mehr sein.
Eine Komposition war die beschriebene Mengenvereiniung bei Topologien und bei Faktorisierungen gibt es die hintereinanderverkettung als Komposition.
Mein Quelltext wird einfach genommen und importiert in andere dateien und py dateien werden wie objekte und klassen behandelt und deren variablen wie Methoden und dann umbenannt zu den Mathe Dingern der höheren Architektur und in diesem Kontext benutzt, sodass legacy code der alten monolitischen Architektur mit neuer stark modularer architektur im Verbund vorliegt und mein Alter Code nicht vollkommen neu geschrieben wurde sondern in stücke geteilt wurde.

Ahh, das sind immer die snapshot Methoden, die die höheren Mathe Dinger als Strings zugehörig zu den jeweiligen Algorithmen machen, zur Klasse die meine Teilalgorithmen geklaut hat per import.
Meine Algorithmen werden jedenfalls umbeannt importiert in die Mathe höheren Dinger Namen, sodass sie mehrfach existieren, in neuem und altem modell, das vieles schon für das neue Modell verloren hat.

oder über code owner attribut verbunden zu mathe dingern sind die code dinger.

Aha, ein Diagram ist ein Funktor. Ein Quadrat ist ein sehr einfaches Diagram, von einem zu einem Punkt sind viele mögliche Wege dazwischen. Ein Diagram sind viele Abbildungen Funktionen.

Wo finden die snapshot Methoden Anwendung?
Als weiteren Snapshot vieler oder aller snapshots.
in probe, also tests.
arch validierung, ob die zur sache nötigen mathe dinger dazu sind, kann man aus dem snapshot entnehmen.
