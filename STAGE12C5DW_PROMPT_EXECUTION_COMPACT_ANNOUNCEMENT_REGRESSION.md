# Stage 12c5dw – Prompt execution compact announcement regression fix

This stage fixes the native `test_prompt_execution.mojo` contract introduced around `PromptExecutionCompactAnnouncementPlan`.

The owner logic was already correct: pure numeric compact prompts such as `15` carry the historical quiet flag `keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar`, so the compact announcement plan must not print a visible echo line for that route.  The failing tests incorrectly expected `15` to be both quiet and visibly echoed.

The visible-line assertion now uses a non-quiet compact command (`a1` -> `absicht 1`), while the quiet assertion explicitly verifies that numeric `15` remains suppressed.

No `.so`/`.dll` split is implemented in this stage.
