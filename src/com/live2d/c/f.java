package com.live2d.c;

import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;
import java.util.regex.Pattern;

public final class f {
    public static final f a = new f();

    private f() {
    }

    public final b a(int i) {
        switch (i) {
            case -1030:
            case -1029:
            case -1017:
            case -3:
            case -1:
            case 0:
                return b.a;
            case -1021:
            case -159:
            case -143:
            case -135:
                return b.e;
            case -1019:
            case -147:
            case -142:
            case -112:
            case -105:
            case -23:
            case -20:
                return b.d;
            case -1011:
                return b.h;
            case -1005:
                return b.f;
            case -149:
                return b.j;
            case -136:
            case -132:
            case -103:
                return b.c;
            default:
                return b.b;
        }
    }

    public final j b(int i) {
        switch (i) {
            case -1030:
                return j.f;
            case -1017:
            case -3:
                return j.e;
            case -1:
                return j.b;
            case 0:
                return j.c;
            default:
                return j.a;
        }
    }

    public final boolean a(String str) {
        if (str == null || str.trim().isEmpty())
            return false;
        if (str.length() != d.a.f().length())
            return false;

        String[] parts = str.split(Pattern.quote(d.a.g()));

        if (parts.length != d.a.h())
            return false;

        for (String part : parts) {
            if (part.length() != d.a.i())
                return false;
        }

        return true;
    }

    public final boolean b(String str) {
        if (str == null)
            return false;
        try {
            return new File(str).exists();
        } catch (Exception e) {
            return false;
        }
    }

    public final c a(String str, String str2) {
        if (str == null || str2 == null)
            throw new NullPointerException();
        if (str2.trim().isEmpty()) {
            return b.i.b();
        }

        try {
            File file = new File(str);
            File parent = file.getCanonicalFile().getParentFile();
            if (!parent.exists() && !parent.mkdirs()) {
                throw new IOException("cannot create license directory.");
            }

            String date = new SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.JAPAN).format(new Date());
            String content = d.a.c() + date + str2;

            try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(file)))) {
                writer.write(content);
            }

            return b.i.b();
        } catch (Exception e) {
            if (com.live2d.util.s.a.c()) {
                e.printStackTrace();
            }
            return c.a.a();
        }
    }

    public final c c(String str) {
        if (!b(str)) {
            return c.a.a();
        }
        try {
            if (!new File(str).delete()) {
                throw new IOException("cannot delete license file.");
            }
            return c.a.a();
        } catch (Exception e) {
            return b.i.b();
        }
    }

    public final boolean d(String str) {
        if (!b(str))
            return false;
        try {
            List<String> lines = java.nio.file.Files.readAllLines(new File(str).toPath());
            if (lines.isEmpty())
                return false;
            for (String line : lines) {
                if (Objects.equals(line, d.a.c()))
                    return true;
            }
        } catch (Exception e) {
        }
        return false;
    }

    public final String a(boolean z) {
        String os = System.getProperty("os.name");
        if (os == null)
            os = "";

        String path = null;

        if (os.contains("Windows")) {
            String env = System.getenv("ALLUSERSPROFILE");
            if (env == null)
                env = "";
            env = env.replace('\\', '/');
            if (z)
                path = env + d.a.k();
            else
                path = env + d.a.j();
        } else if (os.contains("Linux")) {
            String home = System.getProperty("user.home");
            if (z)
                path = home + "/.local/share" + d.a.k();
            else
                path = home + "/.local/share" + d.a.j();
        } else if (os.contains("Mac")) {
            String home = System.getProperty("user.home");
            if (z)
                path = home + "/Library/Application Support" + d.a.k();
            else
                path = home + "/Library/Application Support" + d.a.j();
        }

        if (path == null) {
            String home = System.getProperty("user.home");
            if (z)
                path = home + "/.local/share" + d.a.k();
            else
                path = home + "/.local/share" + d.a.j();
        }

        File f = new File(path);
        if (!f.exists())
            f.mkdirs();

        return path;
    }
}
