import subprocess
import re
import spacy
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datasets import load_dataset
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import GaussianNB
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import VotingClassifier
from transformers import pipeline, BertTokenizer, BertModel
import torch
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score

# Ensure the spacy model is downloaded
subprocess.run(["python", "-m", "spacy", "download", "en_core_web_sm"])

# Load the spacy model
spacy_en = spacy.load('en_core_web_sm')
stopwords = spacy_en.Defaults.stop_words

def clean_text(text):
    text = text.lower()
    text = re.sub(r"[.!?/\-_*:\",'()#@$%^&]", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text

def tokenize_text(text):
    tokens = spacy_en(text)
    result = []
    for token in tokens:
        lemma = token.lemma_
        if lemma not in stopwords:
            result.append(lemma)
    return ' '.join(result)

# Load the dataset
dataset = load_dataset('cornell-movie-review-data/rotten_tomatoes')
df = pd.DataFrame(dataset['test'])

print(df.count())

df["text"] = df["text"].apply(clean_text)
df["text"] = df["text"].apply(tokenize_text)

print(df.head())

print(f"Distribution of classes in the dataset: {df['label'].value_counts()}")

tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
model = BertModel.from_pretrained('bert-base-uncased')

def get_bert_embeddings(text):
    inputs = tokenizer(text, return_tensors='pt', truncation=True, padding=True, max_length=512)
    with torch.no_grad():
        outputs = model(**inputs)
    return outputs.last_hidden_state.mean(dim=1).squeeze().numpy()

df['bert_embeddings'] = df['text'].apply(get_bert_embeddings)
X_bert = np.vstack(df['bert_embeddings'])
y_bert = df['label'].values

X_train_bert, X_test_bert, y_train_bert, y_test_bert = train_test_split(X_bert, y_bert, test_size=0.2, random_state=42)

gnb = GaussianNB()
logreg = LogisticRegression(max_iter=200)
gnb.fit(X_train_bert, y_train_bert)
logreg.fit(X_train_bert, y_train_bert)

y_pred_gnb = gnb.predict(X_test_bert)
y_pred_logreg = logreg.predict(X_test_bert)

accuracy_gnb = accuracy_score(y_test_bert, y_pred_gnb) * 100
precision_gnb = precision_score(y_test_bert, y_pred_gnb, average='weighted') * 100
recall_gnb = recall_score(y_test_bert, y_pred_gnb, average='weighted') * 100
f1_gnb = f1_score(y_test_bert, y_pred_gnb, average='weighted') * 100

accuracy_logreg = accuracy_score(y_test_bert, y_pred_logreg) * 100
precision_logreg = precision_score(y_test_bert, y_pred_logreg, average='weighted') * 100
recall_logreg = recall_score(y_test_bert, y_pred_logreg, average='weighted') * 100
f1_logreg = f1_score(y_test_bert, y_pred_logreg, average='weighted') * 100

print(f"Naive Bayes Model Performance:")
print(f"Accuracy: {accuracy_gnb:.2f}%")
print(f"Precision: {precision_gnb:.2f}%")
print(f"Recall: {recall_gnb:.2f}%")
print(f"F1 Score: {f1_gnb:.2f}%")

print(f"\nLogistic Regression Model Performance:")
print(f"Accuracy: {accuracy_logreg:.2f}%")
print(f"Precision: {precision_logreg:.2f}%")
print(f"Recall: {recall_logreg:.2f}%")
print(f"F1 Score: {f1_logreg:.2f}%")

ensemble_model = VotingClassifier(estimators=[('gnb', gnb), ('logreg', logreg)], voting='soft')
ensemble_model.fit(X_train_bert, y_train_bert)

y_pred_ensemble = ensemble_model.predict(X_test_bert)
accuracy_ensemble = accuracy_score(y_test_bert, y_pred_ensemble) * 100
precision_ensemble = precision_score(y_test_bert, y_pred_ensemble, average='weighted') * 100
recall_ensemble = recall_score(y_test_bert, y_pred_ensemble, average='weighted') * 100
f1_ensemble = f1_score(y_test_bert, y_pred_ensemble, average='weighted') * 100

print(f"\nEnsemble Model Performance (Naive Bayes & Logistic Regression):")
print(f"Accuracy: {accuracy_ensemble:.2f}%")
print(f"Precision: {precision_ensemble:.2f}%")
print(f"Recall: {recall_ensemble:.2f}%")
print(f"F1 Score: {f1_ensemble:.2f}%")

models = ['Naive Bayes', 'Logistic Regression', 'Ensemble']
accuracies = [accuracy_gnb / 100, accuracy_logreg / 100, accuracy_ensemble / 100]
plt.figure(figsize=(10, 6))
sns.barplot(x=models, y=accuracies, palette="viridis", hue=models, dodge=False)
plt.title('Model Performance')
plt.ylabel('Accuracy')
plt.ylim(0, 1)
plt.show()

def analyze_sentiment_ensemble(text):
    cleaned_text = clean_text(text)
    tokenized_text = tokenize_text(cleaned_text)
    bert_embedding = get_bert_embeddings(tokenized_text).reshape(1, -1)
    ensemble_result = ensemble_model.predict(bert_embedding)[0]
    ensemble_sentiment = "Positive" if ensemble_result == 1 else "Negative"
    return ensemble_sentiment

def analyze_sentiment_hf(text):
    sentiment_pipeline = pipeline('sentiment-analysis')
    result = sentiment_pipeline(text)[0]
    return result

example_text = "One of the best musicals I've ever seen!"
print(f"\nText: {example_text}")

ensemble_sentiment = analyze_sentiment_ensemble(example_text)
print(f"Predicted sentiment (Ensemble): {ensemble_sentiment}")

hf_result = analyze_sentiment_hf(example_text)
print(f"Sentiment (Hugging Face): {hf_result['label']}")
print(f"Hugging Face prediction details: {hf_result}")

df["predicted_sentiment"] = ensemble_model.predict(np.vstack(df['bert_embeddings']))
plt.figure(figsize=(12, 6))
sns.countplot(x='predicted_sentiment', data=df, palette="viridis", hue='predicted_sentiment', legend=False)
plt.title('Distribution of Predicted Sentiment in Test Dataset')
plt.xlabel('Sentiment')
plt.ylabel('Number of Samples')
plt.xticks(ticks=[0, 1], labels=['Positive', 'Negative'])
plt.show()

df["hf_sentiment"] = df["text"].apply(lambda x: analyze_sentiment_hf(x)['label'])
df["hf_sentiment"] = df["hf_sentiment"].map({'POSITIVE': 1, 'NEGATIVE': 0})

comparison_accuracy = accuracy_score(df["label"], df["hf_sentiment"]) * 100
comparison_precision = precision_score(df["label"], df["hf_sentiment"], average='weighted') * 100
comparison_recall = recall_score(df["label"], df["hf_sentiment"], average='weighted') * 100
comparison_f1 = f1_score(df["label"], df["hf_sentiment"], average='weighted') * 100

print(f"\nHugging Face Model Comparison")
print(f"Accuracy: {comparison_accuracy:.2f}%")
print(f"Precision: {comparison_precision:.2f}%")
print(f"Recall: {comparison_recall:.2f}%")
print(f"F1 Score: {comparison_f1:.2f}%")

