import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
import os
import shutil

class FileCopier:
    def __init__(self):
        self.total_files = 0
        self.copied_files = 0

    def copy_files(self, src_dir, file_type, dest_dir):
        try:
            for filename in os.listdir(src_dir):
                if os.path.isfile(os.path.join(src_dir, filename)) and filename.endswith(file_type):
                    self.total_files += 1
            
            for filename in os.listdir(src_dir):
                if os.path.isfile(os.path.join(src_dir, filename)) and filename.endswith(file_type):
                    src_path = os.path.join(src_dir, filename)
                    dest_path = os.path.join(dest_dir, filename)
                    shutil.copyfile(src_path, dest_path)
                    self.copied_files += 1
                    progress = self.copied_files / self.total_files * 100
                    yield progress
            
            messagebox.showinfo("Success", "Files copied successfully")
            self.update_progress(100)
        except Exception as e:
            messagebox.showerror("Error", str(e))
    

class FileGrabberApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("File Grabber")
        self.geometry("400x200")
        
        self.progress_bar["value"] = 0
        self.progress_bar.pack()

        self.file_copier = FileCopier()

        self.directory_label = ttk.Label(self, text="Source Directory:")
        self.directory_label.place(x=10, y=10)
        self.directory_entry = ttk.Entry(self)
        self.directory_entry.place(x=150, y=10)

        self.file_type_label = ttk.Label(self, text="File Type:")
        self.file_type_label.place(x=10, y=40)
        self.file_type_entry = ttk.Entry(self)
        self.file_type_entry.place(x=150, y=40)

        self.destination_label = ttk.Label(self, text="Destination Directory:")
        self.destination_label.place(x=10, y=70)
        self.destination_entry = ttk.Entry(self)
        self.destination_entry.place(x=150, y=70)

        self.grab_button = ttk.Button(self, text="Grab", command=self.on_grab_clicked)
        self.grab_button.place(x=10, y=100)

        self.progress_bar = ttk.Progressbar(self, orient="horizontal", length=200, mode="determinate")
        self.progress_bar.place(x=10, y=130)

    def on_grab_clicked(self):
        src_dir = self.directory_entry.get()
        file_type = self.file_type_entry.get()
        dest_dir = self.destination_entry.get()
        self.file_copier.copy_files(src_dir, file_type, dest_dir)
        
        progress_gen = self.file_copier(src_dir, file_type, dest_dir)
        for progress in progress_gen:
            self.update_progress(progress)

    def update_progress(self, value):
        self.progress_bar["value"] = value
        self.progress_bar.update_idletasks()

if __name__ == "__main__":
    app = FileGrabberApp()
    app.mainloop()
