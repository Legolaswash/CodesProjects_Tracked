import sys
import matplotlib

def is_notebook():
    """
    Retourne True si le code est exécuté dans un notebook (Jupyter / VS Code interactive).
    """
    try:
        from IPython import get_ipython
        shell = get_ipython().__class__.__name__
        if shell == 'ZMQInteractiveShell':  # Jupyter notebook ou VS Code interactive
            return True
        elif shell == 'TerminalInteractiveShell':  # IPython en terminal
            return False
        else:
            return False  # Autres shells IPython
    except (NameError, ImportError):
        return False  # Pas d'IPython → probablement un script normal

# === Configuration matplotlib ===
if is_notebook():
    # Inline pour notebook / VS Code Interactive
    from IPython import get_ipython
    get_ipython().run_line_magic('matplotlib', 'inline')
else:
    # Popup dans une fenêtre externe (terminal)
    matplotlib.use('Qt5Agg')  # ou 'TkAgg'

import matplotlib.pyplot as plt
import numpy as np

x = np.linspace(0, 10, 100)
y = np.sin(x)

plt.plot(x, y)
plt.title("Détection automatique du mode d'exécution")
plt.show()
