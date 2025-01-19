import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import scipy.signal as signal
import scipy.stats as stats
from scipy.io import loadmat, wavfile
import ttkbootstrap as tb
from ttkbootstrap.constants import *

import tkinter as tk
from tkinter import filedialog, messagebox

class SignalProcessingApp:
    def __init__(self, root):
        self.root = root
        self.root.title("DFA - Analyse de Signal")
        
        # Variables et données
        self.initial_signal = None
        self.current_signal = None
        self.fs = 1
        self.profile = None

        self.rsb_var = tk.DoubleVar(value=5.0)
        self.n_var = tk.IntVar(value=50)
        self.degree_var = tk.IntVar(value=1)  # Nouveau : degré de tendance locale

        # Création de la structure
        self.create_widgets()

    def create_widgets(self):
        control_frame = tb.Frame(self.root)
        control_frame.pack(side=LEFT, fill=Y, padx=10, pady=10)

        display_frame = tb.Frame(self.root)
        display_frame.pack(side=RIGHT, fill=BOTH, expand=True)

        # Figure Matplotlib
        self.fig, self.ax = plt.subplots(figsize=(7,5))
        self.fig.set_facecolor('#f8f9fa')  # fond clair
        self.ax.set_facecolor('#ffffff')
        self.canvas = FigureCanvasTkAgg(self.fig, master=display_frame)
        self.canvas.get_tk_widget().pack(fill=BOTH, expand=True)

        # Boutons et Entrées
        tb.Button(control_frame, text="Charger Signal", bootstyle=PRIMARY, command=self.load_signal).pack(pady=5, fill=X)

        tb.Label(control_frame, text="RSB (dB):").pack(pady=5)
        tb.Entry(control_frame, textvariable=self.rsb_var).pack(pady=5, fill=X)
        tb.Button(control_frame, text="Bruiter", command=self.add_noise).pack(pady=5, fill=X)
        
        tb.Button(control_frame, text="Recharger Signal", command=self.reload_signal).pack(pady=5, fill=X)
        tb.Button(control_frame, text="Périodogramme", command=self.show_periodogram).pack(pady=5, fill=X)
        tb.Button(control_frame, text="Profil", command=self.show_profile).pack(pady=5, fill=X)
        
        tb.Label(control_frame, text="Taille N:").pack(pady=5)
        tb.Entry(control_frame, textvariable=self.n_var).pack(pady=5, fill=X)

        # Nouveau champ pour le degré de tendance
        tb.Label(control_frame, text="Degré de tendance:").pack(pady=5)
        tb.Entry(control_frame, textvariable=self.degree_var).pack(pady=5, fill=X)

        tb.Button(control_frame, text="Découpage Profil & Tendances", command=self.segment_profile).pack(pady=5, fill=X)
        tb.Button(control_frame, text="Résidu", command=self.show_residual).pack(pady=5, fill=X)
        tb.Button(control_frame, text="F2(N) & Hurst", command=self.show_f2n).pack(pady=5, fill=X)

        # Bouton rouge pour quitter
        quit_button = tb.Button(control_frame, text="Quitter", bootstyle=DANGER, command=self.quit_app)
        quit_button.pack(pady=5, fill=tk.X, side=tk.BOTTOM)
    
    def quit_app(self):
        self.root.quit()  # Ferme la boucle mainloop

    def load_signal(self):
        file_path = filedialog.askopenfilename(filetypes=[("MAT files", "*.mat"), ("WAV files", "*.wav")])
        if file_path:
            try:
                if file_path.endswith('.mat'):
                    mat_contents = loadmat(file_path)
                    found_key = None
                    for key in mat_contents.keys():
                        if not key.startswith('__'):
                            found_key = key
                            break
                    if found_key is None:
                        messagebox.showerror("Erreur", "Aucune variable de signal trouvée dans le fichier .mat.")
                        return
                    self.initial_signal = mat_contents[found_key].flatten().astype(float)
                    self.fs = 1
                else:
                    self.fs, data = wavfile.read(file_path)
                    if data.ndim > 1:
                        data = data[:,0]  # si stéréo, garder un canal
                    self.initial_signal = data.astype(np.float64)
                
                # Normalisation facultative pour éviter grandes échelles
                if np.max(np.abs(self.initial_signal)) > 0:
                    self.initial_signal = self.initial_signal / np.max(np.abs(self.initial_signal))

                self.current_signal = self.initial_signal.copy()
                self.plot_signal(self.current_signal, title="Signal Initial")
            except Exception as e:
                messagebox.showerror("Erreur", f"Impossible de charger le signal.\n{e}")

    def add_noise(self):
        if self.current_signal is not None:
            try:
                rsb = self.rsb_var.get()
                self.current_signal = ajouter_bruit(rsb, self.current_signal)
                self.plot_signal(self.current_signal, title=f"Signal Bruité (RSB={rsb}dB)")
            except Exception as e:
                messagebox.showerror("Erreur", f"Erreur lors de l'ajout du bruit.\n{e}")
        else:
            messagebox.showwarning("Attention", "Veuillez charger un signal d'abord.")

    def reload_signal(self):
        if self.initial_signal is not None:
            self.current_signal = self.initial_signal.copy()
            self.plot_signal(self.current_signal, title="Signal Rechargé")
        else:
            messagebox.showwarning("Attention", "Aucun signal initial à recharger.")

   
    def show_periodogram(self):
        if self.current_signal is not None:
            self.ax.clear()
    
            # Périodogramme standard
            f, Pxx = signal.periodogram(self.current_signal, fs=self.fs)
            
            # Exclure le premier point si trop dominant
            f_std, Pxx_std = f[1:], Pxx[1:]
    
            # Paramètres pour Bartlett
            M = 4
            L = len(self.current_signal)
            seg_length = L // M if M > 0 else L
            if seg_length < 2:
                M = 1
                seg_length = L
    
            if M > 1:
                segments_data = self.current_signal[:M*seg_length].reshape(M, seg_length)
                Pxx_bartlett = np.zeros(seg_length//2+1)
                for seg in segments_data:
                    fb, Pxx_seg = signal.periodogram(seg, fs=self.fs)
                    Pxx_bartlett += Pxx_seg
                Pxx_bartlett /= M
                f_bart, Pxx_bart = fb[1:], Pxx_bartlett[1:]
            else:
                f_bart, Pxx_bart = f_std, Pxx_std
    
            # Daniell
            window = 5
            Pxx_daniell_full = np.convolve(Pxx, np.ones(window)/window, mode='same')
            f_dan, Pxx_dan = f[1:], Pxx_daniell_full[1:]
    
            # Welch
            fw, Pxx_welch = signal.welch(self.current_signal, fs=self.fs, nperseg=1024)
            f_welch, Pxx_w = fw[1:], Pxx_welch[1:]
    
            # Tracé
            self.ax.semilogy(f_std, Pxx_std, color='purple', linewidth=1.5, label='Standard')
            if M > 1:
                self.ax.semilogy(f_bart, Pxx_bart, color='green', linewidth=1.5, linestyle='--', label='Bartlett')
            self.ax.semilogy(f_dan, Pxx_dan, color='orange', linewidth=1.5, linestyle='-.', label='Daniell')
            self.ax.semilogy(f_welch, Pxx_w, color='red', linewidth=1.5, linestyle=':', label='Welch')
    
            self.ax.set_title("Comparaison de Différents Périodogrammes", fontsize=12)
            self.ax.set_xlabel("Fréquence (Hz)")
            self.ax.set_ylabel("Densité Spectrale")
            self.ax.grid(True, linestyle='--', alpha=0.7)
            self.ax.legend(fontsize=10, loc='best')
    
            # Ajustement des axes
            self.ax.relim()
            self.ax.autoscale_view()
            
            self.fig.tight_layout()
            self.canvas.draw()
        else:
            messagebox.showwarning("Attention", "Veuillez charger un signal d'abord.")



    def show_profile(self):
        if self.current_signal is not None:
            self.profile = np.cumsum(self.current_signal - np.mean(self.current_signal))
            self.ax.clear()
            self.ax.plot(self.profile, color='blue', linewidth=1.5)
            self.ax.set_title("Profil du Signal", fontsize=12)
            self.ax.set_xlabel("Échantillons")
            self.ax.set_ylabel("Amplitude cumulée")
            self.ax.grid(True, linestyle='--', alpha=0.7)
            self.ax.autoscale()
            self.canvas.draw()
        else:
            messagebox.showwarning("Attention", "Veuillez charger un signal d'abord.")
    
    def segment_profile(self):
        if self.profile is not None:
            N = self.n_var.get()
            if N <= 0:
                messagebox.showerror("Erreur", "La taille N doit être > 0.")
                return
            segments = int(len(self.profile) / N)
            if segments < 1:
                messagebox.showerror("Erreur", "N est trop grand pour la taille du profil.")
                return

            degree = self.degree_var.get()
            if degree < 0:
                messagebox.showerror("Erreur", "Le degré doit être >= 0.")
                return

            self.ax.clear()
            x = np.arange(len(self.profile))
            # Profil (affiché une seule fois dans la légende)
            self.ax.plot(x, self.profile, label='Profil', color='blue', linewidth=2)

            cmap = plt.get_cmap('tab10')

            first_segment = True
            for i in range(segments):
                idx_start = i * N
                idx_end = idx_start + N
                segment = self.profile[idx_start:idx_end]
                coeffs = np.polyfit(x[idx_start:idx_end], segment, degree)
                trend = np.polyval(coeffs, x[idx_start:idx_end])

                segment_color = cmap(i % 10)

                # Le premier segment aura une légende 'Tendances'
                label_str = 'Tendances' if first_segment else None
                first_segment = False

                self.ax.plot(x[idx_start:idx_end], trend, color=segment_color, 
                             linewidth=2, linestyle='--', label=label_str)

            self.ax.set_title(f"Découpage du Profil en Segments de Taille {N} et Tendances (Degré={degree})", fontsize=12)
            self.ax.set_xlabel("Échantillons")
            self.ax.set_ylabel("Amplitude cumulée")
            self.ax.grid(True, linestyle='--', alpha=0.7)
            self.ax.legend(loc='best', fontsize=10)
            self.ax.autoscale()
            self.canvas.draw()
        else:
            messagebox.showwarning("Attention", "Veuillez afficher le profil d'abord.")


    def show_residual(self):
        if self.profile is not None:
            N = self.n_var.get()
            if N <= 0:
                messagebox.showerror("Erreur", "La taille N doit être > 0.")
                return
            segments = int(len(self.profile) / N)
            if segments < 1:
                messagebox.showerror("Erreur", "N est trop grand pour la taille du profil.")
                return
            residuals = np.array([])
            x = np.arange(len(self.profile))

            for i in range(segments):
                idx_start = i * N
                idx_end = idx_start + N
                segment = self.profile[idx_start:idx_end]
                coeffs = np.polyfit(x[idx_start:idx_end], segment, 1)
                trend = np.polyval(coeffs, x[idx_start:idx_end])
                res = segment - trend
                residuals = np.concatenate((residuals, res))

            self.ax.clear()
            self.ax.plot(residuals, color='red', linewidth=1.5)
            self.ax.set_title("Résidu du Profil", fontsize=12)
            self.ax.set_xlabel("Échantillons")
            self.ax.set_ylabel("Amplitude")
            self.ax.grid(True, linestyle='--', alpha=0.7)
            self.ax.autoscale()
            self.canvas.draw()
        else:
            messagebox.showwarning("Attention", "Veuillez afficher le profil d'abord.")

    def show_f2n(self):
        if self.profile is not None:
            N_values = np.arange(4, 100, 4)
            F_n = []
            x = np.arange(len(self.profile))
            for N in N_values:
                segments = int(len(self.profile) / N)
                if segments < 1:
                    continue
                F_n_N = []
                for i in range(segments):
                    idx_start = i * N
                    idx_end = idx_start + N
                    segment = self.profile[idx_start:idx_end]
                    coeffs = np.polyfit(x[idx_start:idx_end], segment, 1)
                    trend = np.polyval(coeffs, x[idx_start:idx_end])
                    res = segment - trend
                    F_n_N.append(np.sqrt(np.mean(res**2)))
                F_n.append(np.mean(F_n_N))
            N_values = N_values[:len(F_n)]

            self.ax.clear()
            self.ax.loglog(N_values, F_n, 'o-', label='F2(N)', color='green', linewidth=1.5)
            # Ajustement log-log
            slope, intercept, r_value, p_value, std_err = stats.linregress(np.log(N_values), np.log(F_n))
            self.ax.loglog(N_values, np.exp(intercept + slope * np.log(N_values)), 'r--', label=f'Tendance (α={slope:.2f})')
            H = slope - 1
            self.ax.set_title(f"Courbe F2(N), Tendance et H={H:.2f}", fontsize=12)
            self.ax.set_xlabel("log(N)")
            self.ax.set_ylabel("log(F2(N))")
            self.ax.grid(True, linestyle='--', alpha=0.7)
            self.ax.legend()
            self.ax.autoscale()
            self.canvas.draw()
        else:
            messagebox.showwarning("Attention", "Veuillez afficher le profil d'abord.")

    def plot_signal(self, data, title=""):
        self.ax.clear()
        self.ax.plot(data, color='blue', linewidth=1)
        self.ax.set_title(title, fontsize=12)
        self.ax.set_xlabel("Échantillons")
        self.ax.set_ylabel("Amplitude")
        self.ax.grid(True, linestyle='--', alpha=0.7)
        self.ax.autoscale()
        self.canvas.draw()

def ajouter_bruit(RSB, signal):
    signal_power = np.mean(signal**2)
    noise_power = signal_power / (10**(RSB / 10))
    noise = np.random.normal(0, np.sqrt(noise_power), size=signal.shape)
    return signal + noise

if __name__ == "__main__":
    root = tb.Window(themename="flatly")
    app = SignalProcessingApp(root)
    root.mainloop()
