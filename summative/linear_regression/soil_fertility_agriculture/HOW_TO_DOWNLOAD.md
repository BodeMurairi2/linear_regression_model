# Soil Fertility & Agriculture — AfSIS Soil Dataset

I could not download this automatically: it's hosted as a Kaggle competition
dataset, which requires a logged-in Kaggle account and accepting the
competition rules in the browser before any download (API token) can work.

## Manual steps (~5 minutes)

1. Create a free account at kaggle.com if you don't have one.
2. Go to the competition: search "Africa Soil Property Prediction Challenge"
   on Kaggle (hosted by AfSIS - Africa Soil Information Service).
3. Click "Join Competition" / accept the rules.
4. Download `train.csv` and `test.csv` from the Data tab, or:
   - Go to kaggle.com/settings/account -> "Create New API Token" to get
     `kaggle.json`, place it at `~/.kaggle/kaggle.json`, then run:
     ```
     pip install kaggle
     kaggle competitions download -c afsis-soil-properties -p .
     unzip afsis-soil-properties.zip
     ```
5. Put the extracted CSV(s) in this folder.

Target variables (pick one or predict multiple): Ca, P, pH, SOC, Sand
(soil chemical/physical properties). Features: infrared spectral
reflectance bands (~3,600 columns) + depth + spatial location — this
is one of the richer datasets on the list (large volume + high variety).
