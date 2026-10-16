
# Family & Friends vote: setup (about 10 minutes, free)

Everyone opens the same home page. Friends type their name, then rate each name Love / Like / Pass. Their picks go to a free Supabase database, so everyone's results combine on the scoreboard. Meg and Cathleen's duels are never touched by friends' votes.

## 1. Create the database
1. Go to https://supabase.com and sign up (free).
2. Click **New project**. Name it `name-duel`, choose a database password (save it), pick the nearest region, click **Create**. Wait ~2 minutes.

## 2. Create the tables and rules
1. In the left bar open **SQL Editor** → **New query**.
2. Open `family-setup.sql`, copy everything, paste it in.
3. On the line `insert into family_list ... 'CHOOSE-A-SECRET'` replace `CHOOSE-A-SECRET` with a secret only you know (this is your **admin key**; it lets you publish the name list and Meg and Cathleen's progress).
4. Click **Run**. You should see "Success".

Already ran an earlier version? Run the whole file again. It is safe to repeat, and the last section adds the duel-progress functions friends need to see Meg and Cathleen's status.

## 3. Copy your keys
1. At the top of your project page, click the **Connect** button. In the **.env.local** tab, `..._SUPABASE_URL=` is your Project URL and `..._PUBLISHABLE_KEY=` is your key (ignore the Next.js wording). The dialog shows the **Project URL** (looks like `https://abcd.supabase.co`) and the **publishable key** (starts with `sb_publishable_`). Copy both.
2. Can't see them? The key is also under **Settings → API Keys**. Older projects show an **anon public** key there instead (a long string starting with `eyJ`); either one works. The URL is also under **Integrations → Data API**.
3. Open `config.js` and replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` with them. Never paste a **secret** or **service_role** key. The publishable/anon key is meant to be public; the tables are locked so it can only call the functions you ran in step 2.

## 4. Publish the site
Upload `index.html`, `support.js`, `config.js`, and `uploads/` to your GitHub Pages repo (replace the old files). Wait ~1 minute.

## 5. Choose the names friends see
1. On the home page, scroll to the footer and click **Manage names**. Enter your admin key.
2. **Names** tab: tap **☆ Add to family vote** on the ~20 names you want (it turns teal ★).
3. **Settings** → type your admin key → **Publish family list**. Re-publish any time you change the picks.

## 6. Show Meg and Cathleen's progress
On the device where Meg and Cathleen play, open **Manage names** and enter the admin key once. After that, their status (not started, in progress, finished), winning name and full ranking are shared automatically after each pick. Friends see it on the home page.

## 7. Share
Send friends the site address. No special link needed.

Friends enter just their name. Coming back with the same name shows their past rankings and lets them start a new one. Old rankings are kept; the newest one counts on the scoreboard. If a name is already taken, they add a last initial.

## Meg and Cathleen's duels
Click **🔒 Meg & Cathleen's duels** at the top of the home page. Each person's card asks for their PIN (Meg `0182`, Cathleen `4377`) before they can start, resume or view their duels. To change a PIN, edit the `PINS` line near the top of the script in `index.html`.

## Optional: use your Hover domain
Not needed for the database. To use it for the site: GitHub repo → **Settings → Pages → Custom domain**, enter e.g. `names.yourdomain.com`. In Hover → DNS, add a **CNAME** record: host `names`, target `YOUR-GITHUB-USERNAME.github.io`. Tick **Enforce HTTPS** in GitHub once it appears.

## Notes
- Anyone with the site address can vote, and friends have no PIN, so anyone could sign in as someone else by typing their name.
- The duel PINs and the Manage names check live in the page code. They keep casual visitors out, not determined ones. Publishing is always checked against the admin key on the server.
- Free Supabase projects pause after a week of no activity; open the dashboard and click **Restore** if that happens.
