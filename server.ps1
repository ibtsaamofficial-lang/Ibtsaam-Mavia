$source = @"
using System;
using System.IO;
using System.Net;
using System.Threading.Tasks;
using System.Collections.Generic;

public class HighPerfServer {
    private HttpListener listener;
    private string rootDir;
    private Dictionary<string, string> mimeTypes = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase) {
        { ".html", "text/html; charset=utf-8" },
        { ".htm", "text/html; charset=utf-8" },
        { ".css", "text/css; charset=utf-8" },
        { ".js", "application/javascript; charset=utf-8" },
        { ".json", "application/json; charset=utf-8" },
        { ".jpg", "image/jpeg" },
        { ".jpeg", "image/jpeg" },
        { ".png", "image/png" },
        { ".webp", "image/webp" },
        { ".ico", "image/x-icon" },
        { ".mp4", "video/mp4" },
        { ".webm", "video/webm" },
        { ".mov", "video/quicktime" },
        { ".gif", "image/gif" },
        { ".svg", "image/svg+xml" }
    };

    public void Start(string root, int port) {
        rootDir = Path.GetFullPath(root);
        listener = new HttpListener();
        listener.Prefixes.Add("http://localhost:" + port + "/");
        listener.Prefixes.Add("http://127.0.0.1:" + port + "/");
        listener.Start();
        Console.WriteLine("Server running at http://localhost:" + port + "/");

        Task.Run(async () => {
            while (listener.IsListening) {
                try {
                    var ctx = await listener.GetContextAsync();
                    ProcessRequest(ctx);
                } catch {
                    if (!listener.IsListening) break;
                }
            }
        });
    }

    private async void ProcessRequest(HttpListenerContext ctx) {
        try {
            var req = ctx.Request;
            var res = ctx.Response;
            string relPath = req.Url.LocalPath.TrimStart('/');
            if (string.IsNullOrEmpty(relPath)) relPath = "index.html";
            relPath = Uri.UnescapeDataString(relPath).Replace('/', Path.DirectorySeparatorChar);
            string fullPath = Path.Combine(rootDir, relPath);

            if (File.Exists(fullPath)) {
                string ext = Path.GetExtension(fullPath);
                string mime;
                if (!mimeTypes.TryGetValue(ext, out mime)) mime = "application/octet-stream";

                res.ContentType = mime;
                res.AddHeader("Access-Control-Allow-Origin", "*");
                if (string.Equals(ext, ".html", StringComparison.OrdinalIgnoreCase) || string.Equals(ext, ".htm", StringComparison.OrdinalIgnoreCase)) {
                    res.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate");
                } else {
                    res.AddHeader("Cache-Control", "public, max-age=3600");
                }
                res.AddHeader("Accept-Ranges", "bytes");

                var fileInfo = new FileInfo(fullPath);
                long totalLength = fileInfo.Length;
                long start = 0;
                long end = totalLength - 1;

                string rangeHeader = req.Headers["Range"];
                if (!string.IsNullOrEmpty(rangeHeader) && rangeHeader.StartsWith("bytes=")) {
                    string[] range = rangeHeader.Substring(6).Split('-');
                    long rStart = 0;
                    if (long.TryParse(range[0], out rStart)) start = rStart;
                    long rEnd = 0;
                    if (range.Length > 1 && long.TryParse(range[1], out rEnd)) end = rEnd;
                    if (end >= totalLength) end = totalLength - 1;

                    res.StatusCode = 206;
                    res.AddHeader("Content-Range", string.Format("bytes {0}-{1}/{2}", start, end, totalLength));
                }

                long contentLength = end - start + 1;
                res.ContentLength64 = contentLength;

                if (!string.Equals(req.HttpMethod, "HEAD", StringComparison.OrdinalIgnoreCase)) {
                    using (var fs = new FileStream(fullPath, FileMode.Open, FileAccess.Read, FileShare.Read)) {
                        fs.Seek(start, SeekOrigin.Begin);
                        byte[] buffer = new byte[65536];
                        long remaining = contentLength;
                        while (remaining > 0) {
                            int toRead = (int)Math.Min((long)buffer.Length, remaining);
                            int read = await fs.ReadAsync(buffer, 0, toRead);
                            if (read <= 0) break;
                            await res.OutputStream.WriteAsync(buffer, 0, read);
                            remaining -= read;
                        }
                    }
                }
            } else {
                res.StatusCode = 404;
                byte[] err = System.Text.Encoding.UTF8.GetBytes("404 Not Found");
                res.ContentLength64 = err.Length;
                if (!string.Equals(req.HttpMethod, "HEAD", StringComparison.OrdinalIgnoreCase)) {
                    await res.OutputStream.WriteAsync(err, 0, err.Length);
                }
            }
        } catch {
        } finally {
            try { ctx.Response.Close(); } catch {}
        }
    }

    public void Wait() {
        while (listener != null && listener.IsListening) {
            System.Threading.Thread.Sleep(1000);
        }
    }
}
"@

Add-Type -TypeDefinition $source -Language CSharp
$server = New-Object HighPerfServer
$server.Start($PSScriptRoot, 3000)
$server.Wait()
