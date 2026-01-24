<template>
  <div class="ele-body">
    <el-card shadow="never">
      <!-- 搜索表单 -->
      <el-form :model="where" label-width="77px" class="ele-form-search" @keyup.enter.native="reload"
        @submit.native.prevent>
        <el-row :gutter="15">
          <el-col :lg="6" :md="12">
            <el-form-item label="用户账号:">
              <el-input clearable v-model="where.operName" placeholder="请输入用户账号" />
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <el-form-item label="操作模块:">
              <el-input clearable v-model="where.title" placeholder="请输入操作模块" />
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <div class="ele-form-actions">
              <el-button type="primary" icon="el-icon-search" class="ele-btn-icon" @click="reload">查询
              </el-button>
              <el-button @click="reset">重置</el-button>
            </div>
          </el-col>
        </el-row>
      </el-form>
      <!-- 数据表格 -->
      <ele-pro-table ref="table" :where="where" :datasource="url" :columns="columns" height="calc(100vh - 315px)">
        <!-- 表头工具栏 -->
        <template slot="toolbar">
          <el-button size="small" type="primary" class="ele-btn-icon" icon="el-icon-download" @click="exportData"
            v-if="permission.includes('sys:operlog:export')">导出
          </el-button>
        </template>
        <!-- 操作类型列 -->
        <template slot="logType" slot-scope="{row}">
          <el-tag :type="['info', 'success', 'warning', 'danger', 'primary'][row.operType]" size="mini">
            {{ ['其他', '新增', '修改', '删除', '导出数据', '登录', '登出'][row.operType] }}
          </el-tag>
        </template>
        <!-- 操作状态列 -->
        <template slot="status" slot-scope="{row}">
          <ele-dot :type="['', 'success'][row.status]" :ripple="row.status === 0"
            :text="['操作成功', '操作失败'][row.status]" />
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{row}">
          <el-link type="primary" :underline="false" icon="el-icon-view" @click="openDetail(row)">查看详情
          </el-link>
        </template>
      </ele-pro-table>
    </el-card>
    <!-- 详情弹窗 -->
    <oper-log-detail :visible.sync="showInfo" :data="current || {}" />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import XLSX from 'xlsx';
import OperLogDetail from './operlog-detail';

export default {
  name: 'SystemOperLog',
  components: { OperLogDetail },
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      // 表格数据接口
      url: '/admin/oper/list',
      // 表格列配置
      columns: [
        {
          columnKey: 'selection',
          type: 'selection',
          width: 45,
          align: 'center',
          fixed: "left"
        },
        {
          prop: 'id',
          label: 'ID',
          width: 60,
          align: 'center',
          showOverflowTooltip: true,
          fixed: "left"
        },
        {
          prop: 'title',
          label: '操作模块',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 100
        },
        {
          prop: 'logType',
          label: '操作类型',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 100,
          slot: 'logType'
        },
        {
          prop: 'operName',
          label: '操作账号',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 100
        },
        {
          prop: 'operUrl',
          label: '操作地址',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 150
        },
        {
          prop: 'operIp',
          label: '操作IP',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 130
        },
        // {
        //   prop: 'operLocation',
        //   label: '所属城市',
        //   align: 'center',
        //   showOverflowTooltip: true,
        //   minWidth: 100
        // },
        {
          prop: 'requestMethod',
          label: '请求方法',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 100
        },
        {
          prop: 'status',
          label: '操作状态',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 150,
          slot: 'status'
        },
        {
          prop: 'note',
          label: '备注',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 130
        },
        {
          prop: 'createdAt',
          label: '操作时间',
          sortable: 'custom',
          showOverflowTooltip: true,
          minWidth: 160,
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(new Date(cellValue));
          }
        },
        {
          columnKey: 'action',
          label: '操作',
          width: 90,
          align: 'center',
          resizable: false,
          slot: 'action',
          fixed: "right"
        }
      ],
      // 表格搜索条件
      where: {},
      // 当前选中数据
      current: null,
      // 是否显示查看弹窗
      showInfo: false,
    };
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.$refs.table.reload({ where: this.where });
    },
    /* 重置搜索 */
    reset() {
      this.where = {};
      this.reload();
    },
    /* 详情 */
    openDetail(row) {
      this.current = row;
      this.showInfo = true;
    },
    /* 导出数据 */
    exportData() {
      let array = [['编号ID', '操作模块', '操作类型', '操作账号', '请求方法', '请求地址', '请求IP', 'IP区域', '操作状态', '操作时间']];
      const loading = this.$loading({ lock: true });
      this.$http.get('/sysOperLog/index?page=1&limit=2000').then(res => {
        loading.close();
        if (res.data.code === 200) {
          res.data.data.records.forEach(d => {
            array.push([
              d.id,
              d.title,
              ['其他', '新增', '修改', '删除', '导出数据', '导入模板', '强退', '生成代码', '清空数据', '设置状态'][d.operType],
              d.operName,
              d.operMethod,
              d.operUrl,
              d.operIp,
              d.operLocation,
              ['操作日志', '错误日志'][d.status],
              this.$util.toDateString(d.createTime)
            ]);
          });
          this.$util.exportSheet(XLSX, array, '操作日志');
        } else {
          this.$message.error(res.data.message);
        }
      }).catch(e => {
        loading.close();
        this.$message.error(e.message);
      });
    }
  }
}
</script>

<style scoped></style>
