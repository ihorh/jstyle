Hi devi, before this merges I'd like to suggest a different way to show progress.

Right now the branch counts every row before it starts splitting, so it can show a percentage. That means it reads the whole input twice. On our biggest exports, the counting pass alone takes a good while. I haven't timed it, so I can't give you a number yet.

My suggestion is to drop the pre-count and show rows processed and chunks written instead of a percentage. That way we only read the input once. `split_file()` already reads the input row by row, so the change would only touch this branch's CLI code.

We'd lose the percentage and the ETA, and I know that matters. You've said before that users ask for the bar, so I'm not trying to brush that aside.

There's also a middle ground. We could estimate the percentage by dividing bytes read by the file size, which also skips the pre-count. The problem is accuracy. Rows vary in length, so the estimate will be off on files with long notes. You've talked with the users who want the bar, so you're in a better position than I am to judge whether that's close enough for them.

If it would help us decide, I can time the counting pass on one of the big exports first. What do you think?
