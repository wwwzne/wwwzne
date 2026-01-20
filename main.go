/*wwwzne*/
package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var version = "0.0.0"
var config = "wwwzne.config.json"
var author = `
888       888   888       888   888       888
888   o   888   888   o   888   888   o   888
888  d8b  888   888  d8b  888   888  d8b  888
888 d888b 888   888 d888b 888   888 d888b 888
888d88888b888   888d88888b888   888d88888b888
88888P Y88888   88888P Y88888   88888P Y88888
8888P   Y8888   8888P   Y8888   8888P   Y8888
888P     Y888   888P     Y888   888P     Y888
                                             
888888888888P   d888b    888b   d088888888889
       d888P    d8888b   888b   d0888b       
      d888P     d88888b  888b   d0888b       
     d888P      d888Y88b 888b   d08888888b   
    d888P       d888 Y88b888b   d0888b999b   
   d888P        d888  Y88888b   d0888b       
  d888P         d888   Y8888b   d0888b       
d888888888888   d888    Y888b   d088888888889
`
var ex, err1 = os.Executable()
var exePath = filepath.Dir(ex)
var wd, err2 = os.Getwd()
var exeName = filepath.Base(os.Args[0])

func main() {
	viper.SetConfigType("json")
	// 根指令
	var rootCmd = &cobra.Command{
		Use: exeName, Short: "", Long: `wwwzne为一个简洁的可自定义的命令行工具`,
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println(author)
		},
	}
	// help 子指令
	rootCmd.SetHelpCommand(&cobra.Command{
		Use: "help [command]", Short: "显示任何命令的帮助信息", Long: `展示某个命令的具体用法（如：wwwzne help version）`,
		Run: func(c *cobra.Command, args []string) {
			cmd, _, e := c.Root().Find(args)
			if cmd == nil || e != nil {
				c.Printf("未知命令: %v\n", args)
				return
			}
			err := cmd.Help()
			if err != nil {
				return
			}
		},
	})
	// version 子指令
	rootCmd.AddCommand(&cobra.Command{
		Use: "version", Short: "当前版本号", Long: "终端输出当前版本号",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println(version)
		},
	})
	// config 子指令
	rootCmd.AddCommand(&cobra.Command{
		Use: "config", Short: "配置文件路径", Long: "终端输出配置文件路径",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Printf("全局配置文件: %s\n", filepath.Join(exePath, config))
			if _, err := os.Stat(filepath.Join(wd, config)); err == nil {
				fmt.Printf("局部配置文件: %s\n", filepath.Join(wd, config))
			}
		},
	})
	// completion 子指令
	rootCmd.AddCommand(&cobra.Command{
		Use:                   "completion [bash|zsh|fish|powershell]",
		Short:                 "生成自动补全脚本",
		Long:                  `生成自动补全脚本(shell)可以实现输入键(tab)时自动提示子命令和参数`,
		DisableFlagsInUseLine: true,
		ValidArgs:             []string{"bash", "zsh", "fish", "powershell"},
		Args:                  cobra.MatchAll(cobra.ExactArgs(1), cobra.OnlyValidArgs),
		Run: func(cmd *cobra.Command, args []string) {
			switch args[0] {
			case "bash":
				_ = cmd.Root().GenBashCompletion(os.Stdout)
			case "zsh":
				_ = cmd.Root().GenZshCompletion(os.Stdout)
			case "fish":
				_ = cmd.Root().GenFishCompletion(os.Stdout, true)
			case "powershell":
				_ = cmd.Root().GenPowerShellCompletion(os.Stdout)
			}
		},
	})
	if err1 == nil {
		globalConfigPath := filepath.Join(exePath, config)
		viper.SetConfigFile(globalConfigPath)
		_ = viper.ReadInConfig()
	}
	if err2 == nil {
		localConfigPath := filepath.Join(wd, config)
		viper.SetConfigFile(localConfigPath)
		_ = viper.MergeInConfig()
	}

	shellConfig := viper.GetString("shell")
	settings := viper.AllSettings()
	delete(settings, "shell")
	for key, val := range settings {
		script, ok := val.(string)
		if !ok {
			continue
		}
		cmdName := key
		cmdScript := script
		cmd := &cobra.Command{
			Use: cmdName, Short: fmt.Sprintf("执行指令: %s", cmdScript),
			Run: func(cmd *cobra.Command, args []string) { runWithShell(shellConfig, cmdScript) },
		}
		rootCmd.AddCommand(cmd)
	}
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
func runWithShell(shellType string, script string) {
	var bin string
	var args []string
	mode := strings.ToLower(shellType)
	if mode == "" || mode == "default" {
		if runtime.GOOS == "windows" {
			bin = "cmd"
			args = []string{"/C"}
		} else {
			bin = "sh"
			args = []string{"-c"}
		}
	} else if mode == "powershell" || mode == "pwsh" {
		bin = "powershell"
		args = []string{"-NoProfile", "-Command"}
	} else if mode == "bash" || mode == "sh" || mode == "zsh" {
		bin = mode
		args = []string{"-c"}
	} else if mode == "cmd" {
		bin = "cmd"
		args = []string{"/C"}
	} else {
		bin = shellType
		args = []string{}
	}
	finalArgs := append(args, script)
	cmd := exec.Command(bin, finalArgs...)
	if err1 == nil {
		cmd.Env = append(os.Environ(), "wwwznepath="+exePath)
	}
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Printf("执行错误: %v\n", err)
	}
}
