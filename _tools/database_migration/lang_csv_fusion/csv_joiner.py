import pandas as pd

def read_csv_smart(path):
    for enc in ['utf-8', 'cp1252', 'latin-1']:
        try:
            return pd.read_csv(path, encoding=enc)
        except UnicodeDecodeError:
            continue
    raise ValueError(f"Could not decode {path}")

df1 = read_csv_smart('npc_template.csv')
df2 = read_csv_smart('lang_npc_template.csv')

merged_df = pd.merge(df1, df2, on='id', how='outer')
merged_df.to_csv('merged_output.csv', index=False)