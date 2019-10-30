import 'package:note_app/Note.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  Future<List<Note>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final kdf = prefs.getString('json') ?? [];
    var notes = noteFromJson(kdf);
    return notes;
  }

  save(value) async {
    final prefs = await SharedPreferences.getInstance();
    final vale = noteToJson(value);
    prefs.setString('json', vale);
  }

  remove(int key) async {
    final prefs = await SharedPreferences.getInstance();
    final kdf = prefs.getString('json');
    final notes = noteFromJson(kdf);
    notes.removeWhere((item) => item.id == key);
    if (notes.isEmpty) {
      await prefs.remove('json');
    } else {
      await save(notes);
    }
  }

  Future<bool> done(int key) async {
    final prefs = await SharedPreferences.getInstance();
    final kdf = prefs.getString('json');
    final notes = noteFromJson(kdf);
    for (int i = 0; i < notes.length; i++) {
      if (notes[i].id == key) {
        notes[i].isDone = !notes[i].isDone;
        break;
      }
    }
    await save(notes);
    return true;
  }

  Future<bool> saveNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final kdf = prefs.getString('json') ?? "[]";
    final notes = noteFromJson(kdf);
    notes.insert(0, note);
    await save(notes);
    return true;
  }
}
