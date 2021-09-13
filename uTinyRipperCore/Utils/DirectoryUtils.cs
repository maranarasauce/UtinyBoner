using System;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;

namespace uTinyRipper
{
	public static class DirectoryUtils
	{
		public static bool Exists(string path)
		{
			return Directory.Exists(ToLongPath(path));
		}

		public static DirectoryInfo CreateDirectory(string path)
		{
			return Directory.CreateDirectory(ToLongPath(path));
		}

		public static void CreateVirtualDirectory(string path)
		{
#if !VIRTUAL
			CreateDirectory(path);
#endif
		}

		public static void Delete(string path)
		{
			Directory.Delete(ToLongPath(path, true));
		}

		public static void Delete(string path, bool recursive)
		{
			Directory.Delete(ToLongPath(path, true), recursive);
		}

		public static string[] GetFiles(string path)
		{
			return Directory.GetFiles(ToLongPath(path));
		}

		public static string[] GetFiles(string path, string searchPattern)
		{
			return Directory.GetFiles(ToLongPath(path), searchPattern);
		}

		public static string[] GetFiles(string path, string searchPattern, SearchOption searchOptions)
		{
			return Directory.GetFiles(ToLongPath(path), searchPattern, searchOptions);
		}

		public static DirectoryInfo GetParent(string path)
		{
			return Directory.GetParent(ToLongPath(path));
		}

		public static string ToLongPath(string path)
		{
			return ToLongPath(path, false);
		}

		public static string ToLongPath(string path, bool force)
		{
			if (true) //RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
			{
				if (RunetimeUtils.IsRunningOnNetCore)
				{
					return path;
				}
				if (path.StartsWith(LongPathPrefix, StringComparison.Ordinal))
				{
					return path;
				}

				string fullPath = FileUtils.GetFullPath(path);
				if (force || fullPath.Length >= MaxDirectoryLength)
				{
					return $"{LongPathPrefix}{fullPath}";
				}
			}
			return path;
		}

		public static string FixInvalidPathCharacters(string path)
		{
			return PathRegex.Replace(path, string.Empty);
		}

		// Credits to https://stackoverflow.com/questions/58744/copy-the-entire-contents-of-a-directory-in-c-sharp
		public static void CopyDirectoryFiles(string sourcePath, string targetPath) {
			// Now Create all of the directories
			foreach (string dirPath in Directory.GetDirectories(sourcePath, "*", SearchOption.AllDirectories))
				Directory.CreateDirectory(dirPath.Replace(sourcePath, targetPath));
			// Copy all the files & Replaces any files with the same name
			foreach (string newPath in Directory.GetFiles(sourcePath, "*.*", SearchOption.AllDirectories))
				File.Copy(newPath, newPath.Replace(sourcePath, targetPath), true);
		}

		private static Regex GeneratePathRegex()
		{
			string invalidChars = new string(Path.GetInvalidFileNameChars().Except(new char[] { '\\', '/' }).ToArray());
			string escapedChars = Regex.Escape(invalidChars);
			return new Regex($"[{escapedChars}]");
		}

		public const string LongPathPrefix = @"\\?\";
		public const int MaxDirectoryLength = 248;

		private static readonly Regex PathRegex = GeneratePathRegex();
	}
}
